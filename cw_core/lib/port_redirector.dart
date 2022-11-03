import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:cw_core/proxy_settings_store.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:flutter/foundation.dart';
import 'socks5.dart';

class PortRedirector {
  PortRedirector._(
    SettingsStore settingsStore,
    String serverHost,
    int serverPort,
    {Duration timeout}) {

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

  static Future<PortRedirector> start(
    SettingsStore settingsStore,
    String serverHost,
    int serverPort,
    {Duration timeout}) async {

      int now  = DateTime.now().millisecondsSinceEpoch;
      if (settingsStore.proxyEnabled &&
          settingsStore.portScanEnabled &&
          nextScanTimestamp < now) {

        bool error = false;
        try {
          _connectToProxy(
            settingsStore, serverHost, serverPort, Duration(seconds: 1));
        } catch(_) {
          error = true;
        }
        if (error) {
          nextScanTimestamp = now + portScanPeriod;
          for (int proxyPort = 40000; proxyPort < 65536; ++proxyPort) {
            try {
              await SOCKSSocket.connect(
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

      return await _startInternal(
        settingsStore, serverHost, serverPort, timeout: timeout);
  }

  static Future<SOCKSSocket> _connectToProxy(
    SettingsStore settingsStore, String host, int port, Duration timeout) {

    int proxyPort = 0;
    try {
      proxyPort = int.parse(settingsStore.proxyPort);
    } catch (_) {}

    if (settingsStore.proxyAuthenticationEnabled) {
      return SOCKSSocket.connect(
        settingsStore.proxyIPAddress, proxyPort, host, port,
        timeout: timeout, username: settingsStore.proxyUsername,
        password: settingsStore.proxyPassword);
    } else {
      return SOCKSSocket.connect(
        settingsStore.proxyIPAddress, proxyPort, host, port,
        timeout: timeout);
    }
  }

  static Future<PortRedirector> _startInternal(
    SettingsStore settingsStore,
    String serverHost,
    int serverPort,
    {Duration timeout}) async {

    PortRedirector redirector = PortRedirector._(
      settingsStore, serverHost, serverPort, timeout: timeout);

    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn<Map<String, dynamic>>(
      invokeListenerIsolate,
      {"listenerHost": redirector.host, "serverHost": serverHost,
        "serverPort": serverPort, "timeout": timeout,
        "sendPort": receivePort.sendPort});

    dynamic received = await receivePort.first;
    if (received is List<dynamic>) {
      redirector._listenerPort = received[0];
      settingsStore.proxySettingsListeners.add((dynamic settings) {
        received[1].send(ProxySettingsStore.fromSettingsStore(settings));
      });
      received[1].send(ProxySettingsStore.fromSettingsStore(settingsStore));
    } else {
      throw received;
    }
    return redirector;
  }

  static void invokeListenerIsolate(Map<String, dynamic> args) async {
    int listenerPort;
    ServerSocket listenerSocket;
    int i = 0;
    for (i=0; i < 10; ++i) {
      try {
        final random = Random();
        listenerPort = 49152 + random.nextInt(16384);

        listenerSocket = await ServerSocket.bind(
          args["listenerHost"], listenerPort);
        break;
      } catch (_) {}
    }

    if (i == 10) {
      args["sendPort"].send("no free port found");
      return;
    }

    SettingsStore settingsStore = SettingsStore(nodes: {});
    List<Socket> sockets = List<Socket>();
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((dynamic data) {
      ProxySettingsStore.setSettingsStore(settingsStore, data);
      for (var socket in sockets) {
        socket.destroy();
      }
      sockets.clear();
    });

    args["sendPort"].send(
      [listenerPort, receivePort.sendPort] as List<dynamic>);

    await _listen(
      listenerSocket, settingsStore, args["serverHost"], args["serverPort"],
      args["timeout"], sockets);
  }

  static Future _listen(
    ServerSocket listenerSocket, SettingsStore settingsStore,
    String serverHost, int serverPort, Duration timeout,
    List<Socket> sockets) async {

    await for (var clientSocket in listenerSocket) {
      ProxySettingsStore oldProxySettings =
        ProxySettingsStore.fromSettingsStore(settingsStore);
      Socket serverSocket;
      StreamSubscription<Uint8List> serverSocketSub;
      if (settingsStore.proxyEnabled) {
        try {
          SOCKSSocket proxySocket = await _connectToProxy(
            settingsStore, serverHost, serverPort, timeout);

          serverSocket = proxySocket.socket;
          serverSocketSub = proxySocket.subscription;
        } catch (_) {
          clientSocket.destroy();
          continue;
        }
      } else {
        try {
          serverSocket = await Socket.connect(
            serverHost, serverPort, timeout: timeout);
          serverSocketSub = serverSocket.listen((Uint8List data) {});
        } catch (_) {
          clientSocket.destroy();
          continue;
        }
      }
      if (!oldProxySettings.equals(
            ProxySettingsStore.fromSettingsStore(settingsStore))) {
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

  String _listenerHost;
  int _listenerPort;

  String get host => _listenerHost;
  int get port => _listenerPort;
}