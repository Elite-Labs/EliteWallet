import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info/package_info.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/view_model/proxy_settings/proxy_input_list_item.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';
import 'package:elite_wallet/view_model/proxy_settings/switcher_list_item.dart';
import 'package:elite_wallet/src/screens/proxy_settings/proxy_input_type.dart';

part 'proxy_settings_view_model.g.dart';

class ProxySettingsViewModel =
  ProxySettingsViewModelBase with _$ProxySettingsViewModel;

abstract class ProxySettingsViewModelBase with Store {
  ProxySettingsViewModelBase(this._settingsStore)
    : sections = <List<SettingsListItem>>[] {
      sections = [
        [
          SwitcherListItem(
              title: S.current.proxy_enabled,
              value: () => proxyEnabled,
              onValueChange: (_, bool value) => setProxyEnabled(value)),
          ProxyInputListItem(
              type: ProxyInputType.ipAddress,
              value: () => proxyIPAddress,
              onValueChange: (_, String value) => setProxyIPAddress(value)),
          ProxyInputListItem(
              type: ProxyInputType.port,
              value: () => proxyPort,
              onValueChange: (_, String value) => setProxyPort(value))
        ],
        [
          SwitcherListItem(
              title: S.current.proxy_authentication_enabled,
              value: () => proxyAuthenticationEnabled,
              onValueChange:
                (_, bool value) => setProxyAuthenticationEnabled(value)),
          ProxyInputListItem(
              type: ProxyInputType.username,
              value: () => proxyUsername,
              onValueChange: (_, String value) => setProxyUsername(value)),
          ProxyInputListItem(
              type: ProxyInputType.password,
              value: () => proxyPassword,
              onValueChange: (_, String value) => setProxyPassword(value)),
        ],
        [
          SwitcherListItem(
              title: S.current.proxy_local_port_scan_enabled,
              value: () => portScanEnabled,
              onValueChange: (_, bool value) => setPortScanEnabled(value))
        ]
      ];
    }

  List<List<SettingsListItem>> sections;
  final SettingsStore _settingsStore;

  @computed
  bool get proxyEnabled => _settingsStore.proxyEnabled;

  @computed
  String get proxyIPAddress => _settingsStore.proxyIPAddress;

  @computed
  String get proxyPort => _settingsStore.proxyPort;

  @computed
  bool get proxyAuthenticationEnabled =>
    _settingsStore.proxyAuthenticationEnabled;

  @computed
  String get proxyUsername => _settingsStore.proxyUsername;

  @computed
  String get proxyPassword => _settingsStore.proxyPassword;

  @computed
  bool get portScanEnabled => _settingsStore.portScanEnabled;

  @action
  void setProxyEnabled(bool value) => _settingsStore.proxyEnabled = value;

  @action
  void setProxyIPAddress(String value) =>
    _settingsStore.proxyIPAddress = value;

  @action
  void setProxyPort(String value) {
    if (value == "") {
      _settingsStore.proxyPort = value;
      return;
    }
    try {
      int intValue = int.parse(value);
      _settingsStore.proxyPort = intValue.toString();
    } catch (_) {
    }
  }

  @action
  void setProxyAuthenticationEnabled(bool value) {
    _settingsStore.proxyAuthenticationEnabled = value;
  }

  @action
  void setProxyUsername(String value) =>
    _settingsStore.proxyUsername = value;

  @action
  void setProxyPassword(String value) =>
    _settingsStore.proxyPassword = value;

  @action
  void setPortScanEnabled(bool value) =>
    _settingsStore.portScanEnabled = value;
}
