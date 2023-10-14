import 'dart:io';

import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/keyable.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:ew_core/port_redirector.dart';
import 'package:ew_core/http_port_redirector.dart';

part 'node.g.dart';

Uri createUriFromElectrumAddress(String address) =>
    Uri.tryParse('tcp://$address')!;

@HiveType(typeId: Node.typeId)
class Node extends HiveObject with Keyable {
  Node(
      {this.login,
      this.password,
      this.useSSL,
      this.trusted = false,
      String? uri,
      WalletType? type,}) {
    if (uri != null) {
      uriRaw = uri;
    }
    if (type != null) {
      this.type = type;
    }
  }

  Node.fromMap(Map<String, Object?> map)
      : uriRaw = map['uri'] as String? ?? '',
        login = map['login'] as String?,
        password = map['password'] as String?,
        useSSL = map['useSSL'] as bool?,
        trusted = map['trusted'] as bool? ?? false;

  static const typeId = 1;
  static const boxName = 'Nodes';

  @HiveField(0, defaultValue: '')
  late String uriRaw;

  @HiveField(1)
  String? login;

  @HiveField(2)
  String? password;

  @HiveField(3, defaultValue: 0)
  late int typeRaw;

  @HiveField(4)
  bool? useSSL;

  @HiveField(5, defaultValue: false)
  bool trusted;

  bool get isSSL => useSSL ?? false;

  Uri get uri {
    switch (type) {
      case WalletType.monero:
        return Uri.http(uriRaw, '');
      case WalletType.bitcoin:
        return createUriFromElectrumAddress(uriRaw);
      case WalletType.litecoin:
        return createUriFromElectrumAddress(uriRaw);
      case WalletType.haven:
        return Uri.http(uriRaw, '');
      case WalletType.wownero:
        return Uri.http(uriRaw, '');
      case WalletType.ethereum:
        return Uri.https(uriRaw, '');
      default:
        throw Exception('Unexpected type ${type.toString()} for Node uri');
    }
  }

  @override
  bool operator ==(other) =>
      other is Node &&
          (other.uriRaw == uriRaw &&
              other.login == login &&
              other.password == password &&
              other.typeRaw == typeRaw &&
              other.useSSL == useSSL &&
              other.trusted == trusted);

  @override
  int get hashCode =>
      uriRaw.hashCode ^
      login.hashCode ^
      password.hashCode ^
      typeRaw.hashCode ^
      useSSL.hashCode ^
      trusted.hashCode;

  @override
  dynamic get keyIndex {
    _keyIndex ??= key;
    return _keyIndex;
  }

  WalletType get type => deserializeFromInt(typeRaw);

  set type(WalletType type) => typeRaw = serializeToInt(type);

  dynamic _keyIndex;

  Future<bool> requestNode(SettingsStore settingsStore) async {
    try {
      switch (type) {
        case WalletType.monero:
          return requestMoneroNode(settingsStore);
        case WalletType.wownero:
          return requestMoneroNode(settingsStore);
        case WalletType.bitcoin:
          return requestElectrumServer(settingsStore);
        case WalletType.litecoin:
          return requestElectrumServer(settingsStore);
        case WalletType.haven:
          return requestMoneroNode(settingsStore);
        case WalletType.ethereum:
          return requestEthereumServer(settingsStore);
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestMoneroNode(SettingsStore settingsStore) async {
    final path = '/json_rpc';

    try {

      final rpcUri = isSSL ? Uri.https(uri.authority, path) : Uri.http(uri.authority, path);
      final realm = 'monero-rpc';
      final body = {
          'jsonrpc': '2.0',
          'id': '0',
          'method': 'get_info'
      };
      final authenticatingClient = HttpClient();

      authenticatingClient.addCredentials(
          rpcUri,
          realm,
          HttpClientDigestCredentials(login ?? '', password ?? ''),
      );

      authenticatingClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

      final response = await post(
        settingsStore,
        rpcUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
        httpClient: authenticatingClient);

      final resBody = json.decode(response.body) as Map<String, dynamic>;
      return !(resBody['result']['offline'] as bool);
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestElectrumServer(SettingsStore settingsStore) async {
    try {
      PortRedirector portRedirector;
      String host = uri.host;
      int port = uri.port;
      portRedirector = await PortRedirector.start(
        settingsStore, host, port, timeout: Duration(seconds: 5));
      host = portRedirector.host;
      port = portRedirector.port;

      await SecureSocket.connect(
        host, port, timeout: Duration(seconds: 5),
        onBadCertificate: (_) => true);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestEthereumServer(SettingsStore settingsStore) async {
    try {
      final response = await get(
        settingsStore,
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
