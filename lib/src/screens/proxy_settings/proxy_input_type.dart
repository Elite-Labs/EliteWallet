import 'package:elite_wallet/generated/i18n.dart';

class ProxyInputType {
  final _value;
  const ProxyInputType._(this._value);
  toString() => _value;

  bool isNumberWithDots() {
    return this == ipAddress || this == port;
  }

  static get ipAddress => ProxyInputType._(S.current.proxy_ip_address);
  static get port => ProxyInputType._(S.current.proxy_port);
  static get username => ProxyInputType._(S.current.proxy_username);
  static get password => ProxyInputType._(S.current.proxy_password);
}