import 'package:elite_wallet/store/settings_store.dart';

class ProxySettingsStore {
  static ProxySettingsStore fromSettingsStore(SettingsStore settingsStore) {
    ProxySettingsStore proxySettingsStore = new ProxySettingsStore();
    proxySettingsStore.proxyEnabled = settingsStore.proxyEnabled;
    proxySettingsStore.proxyIPAddress = settingsStore.proxyIPAddress;
    proxySettingsStore.proxyPort = settingsStore.proxyPort;
    proxySettingsStore.proxyAuthenticationEnabled =
      settingsStore.proxyAuthenticationEnabled;
    proxySettingsStore.proxyUsername = settingsStore.proxyUsername;
    proxySettingsStore.proxyPassword = settingsStore.proxyPassword;
    proxySettingsStore.portScanEnabled = settingsStore.portScanEnabled;
    return proxySettingsStore;
  }

  ProxySettingsStore copy() {
    ProxySettingsStore proxySettingsStore = new ProxySettingsStore();
    proxySettingsStore.proxyEnabled = this.proxyEnabled;
    proxySettingsStore.proxyIPAddress = this.proxyIPAddress;
    proxySettingsStore.proxyPort = this.proxyPort;
    proxySettingsStore.proxyAuthenticationEnabled =
      this.proxyAuthenticationEnabled;
    proxySettingsStore.proxyUsername = this.proxyUsername;
    proxySettingsStore.proxyPassword = this.proxyPassword;
    proxySettingsStore.portScanEnabled = this.portScanEnabled;
    return proxySettingsStore;
  }

  bool equals(ProxySettingsStore proxySettingsStore) {
    return
      proxyEnabled == proxySettingsStore.proxyEnabled &&
      proxyIPAddress == proxySettingsStore.proxyIPAddress &&
      proxyPort == proxySettingsStore.proxyPort &&
      proxyAuthenticationEnabled ==
        proxySettingsStore.proxyAuthenticationEnabled &&
      proxyUsername == proxySettingsStore.proxyUsername &&
      proxyPassword == proxySettingsStore.proxyPassword &&
      portScanEnabled == proxySettingsStore.portScanEnabled;
  }

  bool proxyEnabled = false;
  String proxyIPAddress = "";
  String proxyPort = "";
  bool proxyAuthenticationEnabled = false;
  String proxyUsername = "";
  String proxyPassword = "";
  bool portScanEnabled = false;
}