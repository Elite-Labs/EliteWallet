import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:ew_core/proxy_settings_store.dart';
import 'package:elite_wallet/di.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:flutter/foundation.dart';
import 'socks5.dart';

class PortRedirector {
  PortRedirector._(
    String serverHost,
    int serverPort,
    {required Duration timeout}) {

    _listenerHost = "127.0.0.1";
    _listenerPort = 0;
  }

  static final Uint8List httpConnectRequest =
    Uint8List.fromList([67, 79, 78, 78, 69, 67, 84]); // CONNECT
  static final Uint8List httpConnectResponse =
    Uint8List.fromList([
      72, 84, 84, 80, 47, 49, 46, 49, 32, 50, 48, 48, 32, 67, 111, 110, 110,
      101, 99, 116, 105, 111, 110, 32, 69, 115, 116, 97, 98, 108, 105, 115,
      104, 101, 100, 13, 10, 13, 10]);
        // HTTP/1.1 200 Connection Established\r\n\r\n

  static int nextScanTimestamp = 0;
  static final int portScanPeriod = 1000 * 300; // 5 minutes

  static Map<String, PortRedirector> redirectors = {};

  static Future<PortRedirector> start(
    String serverHost,
    int serverPort,
    {required Duration timeout}) async {

    SettingsStore settingsStore = getIt.get<SettingsStore>();
      String mapKey = serverHost + ":" + serverPort.toString();
      if (redirectors.containsKey(mapKey))
        return redirectors[mapKey]!;

      int now  = DateTime.now().millisecondsSinceEpoch;
      if (settingsStore.proxyEnabled &&
          settingsStore.portScanEnabled &&
          nextScanTimestamp < now) {

        bool error = false;
        try {
          connectToProxy(
            serverHost, serverPort, Duration(seconds: 1));
        } catch(_) {
          error = true;
        }
        if (error) {
          nextScanTimestamp = now + portScanPeriod;
          for (int proxyPort = 40000; proxyPort < 65536; ++proxyPort) {
            try {
              await SocksSocket.connect(
                "127.0.0.1", proxyPort, serverHost, serverPort,
                timeout: Duration(seconds: 1));
              settingsStore.proxyIPAddress = "127.0.0.1";
              settingsStore.proxyPort = proxyPort.toString();
              settingsStore.proxyAuthenticationEnabled = false;
              break;
            } catch(_) {}
          }
        }
      }

      PortRedirector redirector = await _startInternal(
        serverHost, serverPort, timeout: timeout);
      redirectors[mapKey] = redirector;
      return redirector;
  }

  static Future<bool> isProxyValid(ProxySettingsStore proxy) async {
    if (!proxy.proxyEnabled) {
      return true;
    }
    try {
      await connectToProxy(
        proxy.proxyIPAddress, int.parse(proxy.proxyPort),
        Duration(seconds: 1));
      return true;
    } catch (_) {}
    return false;
  }

  static Future<SocksSocket> connectToProxy(
    String host,
    int port,
    Duration timeout) {

    SettingsStore settingsStore = getIt.get<SettingsStore>();
    ProxySettingsStore proxySettingsStore =
      ProxySettingsStore.fromSettingsStore(settingsStore);
    int proxyPort = 0;
    try {
      proxyPort = int.parse(proxySettingsStore.proxyPort);
    } catch (_) {}

    if (proxySettingsStore.proxyAuthenticationEnabled) {
      return SocksSocket.connect(
        proxySettingsStore.proxyIPAddress, proxyPort, host, port,
        timeout: timeout, username: proxySettingsStore.proxyUsername,
        password: proxySettingsStore.proxyPassword);
    } else {
      return SocksSocket.connect(
        proxySettingsStore.proxyIPAddress, proxyPort, host, port,
        timeout: timeout);
    }
  }

  static Future<PortRedirector> _startInternal(
    String serverHost,
    int serverPort,
    {required Duration timeout}) async {

    SettingsStore settingsStore = getIt.get<SettingsStore>();
    PortRedirector redirector = PortRedirector._(
      serverHost, serverPort, timeout: timeout);

    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn<Map<String, dynamic>>(
      invokeListenerIsolate,
      {"listenerHost": redirector.host, "serverHost": serverHost,
        "serverPort": serverPort, "timeout": timeout,
        "sendPort": receivePort.sendPort, "proxy_settings" :
        ProxySettingsStore.fromSettingsStore(settingsStore)});

    dynamic received = await receivePort.first;
    if (received is List<dynamic>) {
      redirector._listenerPort = received[0];
      settingsStore.proxySettingsListeners.add((dynamic settings) {
        received[1].send(ProxySettingsStore.fromSettingsStore(settings));
      });
    } else {
      throw received;
    }
    return redirector;
  }

  static void invokeListenerIsolate(Map<String, dynamic> args) async {
    ServerSocket listenerSocket = await initializeListenerSocket(args);

    await _listen(listenerSocket, args);
  }

  static Future<ServerSocket> initializeListenerSocket(
    Map<String, dynamic> args) async {
    
    for (int i=0; i < 10; ++i) {
      try {
        final random = Random();
        int listenerPort = 49152 + random.nextInt(16384);
        return await ServerSocket.bind(args["listenerHost"], listenerPort);
      } catch (_) {}
    }
    args["sendPort"].send("no free port found");
    throw "No free port found";
  }

  static Future _listen(
    ServerSocket listenerSocket, Map<String, dynamic> args) async {

    String serverHost = args["serverHost"];
    int serverPort = args["serverPort"];
    Duration timeout = args["timeout"];
    List<Socket> sockets = <Socket>[];
    ProxySettingsStore proxySettingsStore = args["proxy_settings"];

    ReceivePort receivePort = ReceivePort();

    receivePort.listen((dynamic data) {
      proxySettingsStore = data;
      for (var socket in sockets) {
        socket.destroy();
      }
      sockets.clear();
    });
    args["sendPort"].send(
      [listenerSocket.port, receivePort.sendPort] as List<dynamic>);

    await for (var clientSocket in listenerSocket) {
      ProxySettingsStore oldProxySettings = proxySettingsStore.copy();
      List<Object> serverSocketRet = await initializeServerSocket(
        proxySettingsStore, serverHost, serverPort, timeout);

      if (serverSocketRet.isEmpty) {
        clientSocket.destroy();
        continue;
      }

      Socket serverSocket = serverSocketRet[0] as Socket;
      StreamSubscription<Uint8List> serverSocketSub =
        serverSocketRet[1] as StreamSubscription<Uint8List>;

      if (!oldProxySettings.equals(proxySettingsStore)) {
        clientSocket.destroy();
        serverSocket.destroy();
        continue;
      }

      // If empty lambda was passed, first few packets would drop
      StreamSubscription<Uint8List> clientSocketSub =
        clientSocket.listen((Uint8List data) {
          serverSocket.add(data);
        });

      _redirectTrafficOneWay(serverSocket, clientSocket, serverSocketSub);
      _redirectTrafficOneWay(clientSocket, serverSocket, clientSocketSub);
      sockets.add(serverSocket);
      sockets.add(clientSocket);
    }
  }

  static Future<List<Object>> initializeServerSocket(
    ProxySettingsStore proxySettingsStore, String serverHost, int serverPort,
    Duration timeout) async {

    if (proxySettingsStore.proxyEnabled) {
      try {
        SocksSocket proxySocket = await connectToProxy(
          serverHost, serverPort, timeout);

        StreamSubscription<Uint8List>? sub = proxySocket.subscription;
        if (sub == null) {
          return <Object>[];
        }

        return [proxySocket.socket, sub];
      } catch (_) {}
    } else {
      try {
        Socket socket =
          await Socket.connect(serverHost, serverPort, timeout: timeout);
        return [socket, socket.listen((Uint8List data) {})];
      } catch (_) {}
    }
    return <Object>[];
  }

  static void _redirectTrafficOneWay(
    Socket from,
    Socket to,
    StreamSubscription<Uint8List> fromSub) {

    fromSub.onData((Uint8List data) {
      if (_isHttpConnectRequest(data)) {
        from.add(httpConnectResponse);
        return;
      }
      to.add(data); 
    });
    fromSub.onError((Object error) {
      to.destroy();
      from.destroy();
    });
    fromSub.onDone(() {
      to.destroy();
      from.destroy();
    });
  }

  static bool _isHttpConnectRequest(Uint8List data) {
    if (data.length < httpConnectRequest.length) {
      return false;
    }
    return listEquals(
      httpConnectRequest,
      Uint8List.sublistView(data, 0, httpConnectRequest.length));
  }

  String _listenerHost = "";
  int _listenerPort = 0;

  String get host => _listenerHost;
  int get port => _listenerPort;
}