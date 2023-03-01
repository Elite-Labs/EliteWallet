library socks;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

/// https://tools.ietf.org/html/rfc1928
/// https://tools.ietf.org/html/rfc1929
///
const SocksVersion = 0x05;
const RFC1929Version = 0x01;

class AuthMethods {
  static const NoAuth = const AuthMethods._(0x00);
  static const GSSApi = const AuthMethods._(0x01);
  static const UsernamePassword = const AuthMethods._(0x02);
  static const NoAcceptableMethods = const AuthMethods._(0xFF);

  final int _value;

  const AuthMethods._(this._value);

  String toString() {
    switch (_value) {
      case 0x00:
        return "AuthMethods.NoAuth";
      case 0x01:
        return "AuthMethods.GSSApi";
      case 0x02:
        return "AuthMethods.UsernamePassword";
      case 0xFF:
        return "AuthMethods.NoAcceptableMethods";
    }
    return "";
  }
}

class SocksState {
  static const Starting = const SocksState._(0x00);
  static const Auth = const SocksState._(0x01);
  static const RequestReady = const SocksState._(0x02);
  static const Connected = const SocksState._(0x03);
  static const AuthStarted = const SocksState._(0x04);
  static const Error = const SocksState._(0x05);

  final int _value;

  const SocksState._(this._value);

  String toString() {
    switch (_value) {
      case 0x00:
        return "SocksState.Starting";
      case 0x01:
        return "SocksState.Auth";
      case 0x02:
        return "SocksState.RequestReady";
      case 0x03:
        return "SocksState.Connected";
      case 0x04:
        return "SocksState.AuthStarted";
      case 0x05:
        return "SocksState.Error";
    }
    return "";
  }
}

class SocksAddressType {
  static const IPv4 = const SocksAddressType._(0x01);
  static const Domain = const SocksAddressType._(0x03);
  static const IPv6 = const SocksAddressType._(0x04);

  final int _value;

  const SocksAddressType._(this._value);

  String toString() {
    switch (_value) {
      case 0x01:
        return "SocksAddressType.IPv4";
      case 0x03:
        return "SocksAddressType.Domain";
      case 0x04:
        return "SocksAddressType.IPv6";
    }
    return "";
  }
}

class SocksCommand {
  static const Connect = const SocksCommand._(0x01);
  static const Bind = const SocksCommand._(0x02);
  static const UDPAssociate = const SocksCommand._(0x03);

  final int _value;

  const SocksCommand._(this._value);

  String toString() {
    switch (_value) {
      case 0x01:
        return "SocksCommand.Connect";
      case 0x02:
        return "SocksCommand.Bind";
      case 0x03:
        return "SocksCommand.UDPAssociate";
    }
    return "";
  }
}

class SocksReply {
  static const Success = const SocksReply._(0x00);
  static const GeneralFailure = const SocksReply._(0x01);
  static const ConnectionNotAllowedByRuleset = const SocksReply._(0x02);
  static const NetworkUnreachable = const SocksReply._(0x03);
  static const HostUnreachable = const SocksReply._(0x04);
  static const ConnectionRefused = const SocksReply._(0x05);
  static const TTLExpired = const SocksReply._(0x06);
  static const CommandNotSupported = const SocksReply._(0x07);
  static const AddressTypeNotSupported = const SocksReply._(0x08);

  final int _value;

  const SocksReply._(this._value);

  String toString() {
    switch (_value) {
      case 0x00:
        return "SocksReply.Success";
      case 0x01:
        return "SocksReply.GeneralFailure";
      case 0x02:
        return "SocksReply.ConnectionNotAllowedByRuleset";
      case 0x03:
        return "SocksReply.NetworkUnreachable";
      case 0x04:
        return "SocksReply.HostUnreachable";
      case 0x05:
        return "SocksReply.ConnectionRefused";
      case 0x06:
        return "SocksReply.TTLExpired";
      case 0x07:
        return "SocksReply.CommandNotSupported";
      case 0x08:
        return "SocksReply.AddressTypeNotSupported";
    }
    return "";
  }
}

class SocksRequest {
  final int version = SocksVersion;
  final SocksCommand command;
  final SocksAddressType addressType;
  final Uint8List address;
  final int port;

  String getAddressString() {
    if (addressType == SocksAddressType.Domain) {
      return AsciiDecoder().convert(address);
    } else if (addressType == SocksAddressType.IPv4) {
      return address.join(".");
    } else if (addressType == SocksAddressType.IPv6) {
      var ret = <String>[];
      for (var x = 0; x < address.length; x += 2) {
        ret.add(
            "${address[x].toRadixString(16).padLeft(2, "0")}${address[x + 1].toRadixString(16).padLeft(2, "0")}");
      }
      return ret.join(":");
    }
    return "";
  }

  SocksRequest({
    required this.command,
    required this.addressType,
    required this.address,
    required this.port,
  });
}

class SocksSocket {
  List<AuthMethods> _auth;
  Socket _sock;
  SocksRequest? _request;

  StreamSubscription<Uint8List>? _sockSub;

  StreamSubscription<Uint8List>? get subscription => _sockSub;

  Socket get socket => _sock;

  SocksState _state;
  final StreamController<SocksState> _stateStream = StreamController<SocksState>();

  SocksState get state => _state;

  Stream<SocksState> get stateStream => _stateStream.stream;

  /// For username:password auth
  final String? username;
  final String? password;
  final Duration timeout;

  Object _exception;

  /// Waits for state to change to [SocksState.Connected]
  /// If the connection request returns an error from the
  /// socks server it will be thrown as an exception in the stream
  ///
  ///
  Future<SocksState> get _waitForConnect =>
      stateStream.firstWhere((a) => a == SocksState.Connected ||
                                    a == SocksState.Error);

  SocksSocket._(Socket socket, {
    required this.timeout,
    this.username,
    this.password,
    List<AuthMethods> auth = const [AuthMethods.NoAuth]
  }) : _auth = auth,
       _sock = socket,
       _state = SocksState.Starting,
       _exception = Object() {
    _setState(SocksState.Starting);
  }

  void _setState(SocksState ns) {
    _state = ns;
    _stateStream.add(ns);
  }

  void _setError(Object exception) {
    _setState(SocksState.Error);
    _exception = exception;
  }

  static Future<SocksSocket> connect(
      dynamic proxyHost,
      int proxyPort,
      dynamic host,
      int port,
      {required Duration timeout,
       String? username,
       String? password}) async {

    Socket tempSocket = await Socket.connect(
      proxyHost, proxyPort, timeout: timeout);

    SocksSocket proxy;
    if (username != null && password != null) {
      proxy = SocksSocket._(tempSocket,
                            auth: [AuthMethods.UsernamePassword],
                            username: username,
                            password: password,
                            timeout: timeout);
    } else {
      proxy = SocksSocket._(tempSocket, timeout: timeout);
    }
    await proxy._connectInternal("$host:$port");

    return proxy;
  }

  /// Issue connect command to proxy
  ///
  Future _connectInternal(String domain) async {
    final ds = domain.split(':');
    assert(ds.length == 2, "Domain must contain port, example.com:80");

    _request = SocksRequest(
      command: SocksCommand.Connect,
      addressType: SocksAddressType.Domain,
      address: AsciiEncoder().convert(ds[0]).sublist(0, ds[0].length),
      port: int.tryParse(ds[1]) ?? 80,
    );

    if (timeout != null) {
      Future.delayed(timeout, () {
        if (_state != SocksState.Connected && _state != SocksState.Error) {
          _sock.destroy();
          _setError("Socks connection timeout");
        }
      });
    }

    await _start();
    await _waitForConnect;
    if (_state == SocksState.Error) {
      throw _exception;
    }
  }

  Future connectIp(InternetAddress ip, int port) async {
    _request = SocksRequest(
      command: SocksCommand.Connect,
      addressType: ip.type == InternetAddressType.IPv4
          ? SocksAddressType.IPv4
          : SocksAddressType.IPv6,
      address: ip.rawAddress,
      port: port,
    );
    await _start();
    await _waitForConnect;
  }

  Future close({bool keepOpen = true}) async {
    await _stateStream.close();
    if (!keepOpen) {
      await _sock.close();
    }
  }

  Future _start() async {
    // send auth methods
    _setState(SocksState.Auth);
    //print(">> Version: 5, AuthMethods: $_auth");
    _sock.add([
      0x05,
      _auth.length,
      ..._auth.map((v) => v._value)
    ]);

    _sockSub = _sock.listen((Uint8List data) {
      _handleRead(data);
    }, onError: (Object error) {
      _setError("Socsk connection error: " + error.toString());
    }, onDone: () {
      _sock.destroy();
      _setError("Connection closed unexpectedly");
    }, cancelOnError: true);
  }

  void _sendUsernamePassword(String uname, String password) {
    if (uname.length > 255 || password.length > 255) {
      _setError("Username or Password is too long");
      return;
    }

    final data = [
      RFC1929Version,
      uname.length,
      ...AsciiEncoder().convert(uname),
      password.length,
      ...AsciiEncoder().convert(password)
    ];

    //print(">> Sending $username:$password");
    _sock.add(data);
  }

  void _handleRead(Uint8List data) async {
    if (_request == null) {
      throw "_request can't be null";
    }
    if (state == SocksState.Auth) {
      if (data.length == 2) {
        final version = data[0];
        final auth = AuthMethods._(data[1]);

        //print("<< Version: $version, Auth: $auth");

        if (auth._value == AuthMethods.UsernamePassword._value) {
          if (username == null || password == null) {
            throw "username and password must be non null";
          }
          _setState(SocksState.AuthStarted);
          _sendUsernamePassword(username!, password!);
        } else if (auth._value == AuthMethods.NoAuth._value) {
          _setState(SocksState.RequestReady);
          _writeRequest(_request!);
        } else if (auth._value == AuthMethods.NoAcceptableMethods._value) {
          _setError("No auth methods acceptable");
        }
      } else {
        _setError("Expected 2 bytes");
      }
    } else if (_state == SocksState.AuthStarted) {
      if (_auth.contains(AuthMethods.UsernamePassword)) {
        final version = data[0];
        final status = data[1];

        if (version != RFC1929Version || status != 0x00) {
          _setError("Invalid username or password");
        } else {
          _setState(SocksState.RequestReady);
          _writeRequest(_request!);
        }
      }
    } else if (_state == SocksState.RequestReady) {
      if (data.length >= 10) {
        final version = data[0];
        final reply = SocksReply._(data[1]);
        //data[2] reserved
        final addrType = SocksAddressType._(data[3]);
        Uint8List addr;
        var port = 0;

        if (addrType == SocksAddressType.Domain) {
          final len = data[4];
          addr = data.sublist(5, 5 + len);
          port = data[5 + len] << 8 | data[6 + len];
        } else if (addrType == SocksAddressType.IPv4) {
          addr = data.sublist(5, 9);
          port = data[9] << 8 | data[10];
        } else if (addrType == SocksAddressType.IPv6) {
          addr = data.sublist(5, 21);
          port = data[21] << 8 | data[22];
        }

        //print("<< Version: $version, Reply: $reply, AddrType: $addrType, Addr: $addr, Port: $port");
        if (reply._value == SocksReply.Success._value) {
          _setState(SocksState.Connected);
        } else {
          _setError(reply);
        }
      } else {
        _setError("Expected 10 bytes");
      }
    }
  }

  void _writeRequest(SocksRequest req) {
    if (_state == SocksState.RequestReady) {
      final data = [
        req.version,
        req.command._value,
        0x00,
        req.addressType._value,
        if (req.addressType == SocksAddressType.Domain)
          req.address.lengthInBytes,
        ...req.address,
        req.port >> 8,
        req.port & 0xFF
      ];

      //print(">> Version: ${req.version}, Command: ${req.command}, AddrType: ${req.addressType}, Addr: ${req.getAddressString()}, Port: ${req.port}");
      _sock.add(data);
    } else {
      _setError("Must be in RequestReady state, current state $_state");
    }
  }
}