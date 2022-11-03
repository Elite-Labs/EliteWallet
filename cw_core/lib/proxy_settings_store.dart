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

  static SettingsStore toSettingsStore(ProxySettingsStore proxySettingsStore) {
    SettingsStore settingsStore = new SettingsStore(nodes: {});
    setSettingsStore(settingsStore, proxySettingsStore);
    return settingsStore;
  }

  static void setSettingsStore(
    SettingsStore settingsStore, ProxySettingsStore proxySettingsStore) {

    settingsStore.proxyEnabled = proxySettingsStore.proxyEnabled;
    settingsStore.proxyIPAddress = proxySettingsStore.proxyIPAddress;
    settingsStore.proxyPort = proxySettingsStore.proxyPort;
    settingsStore.proxyAuthenticationEnabled =
      proxySettingsStore.proxyAuthenticationEnabled;
    settingsStore.proxyUsername = proxySettingsStore.proxyUsername;
    settingsStore.proxyPassword = proxySettingsStore.proxyPassword;
    settingsStore.portScanEnabled = proxySettingsStore.portScanEnabled;
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

  bool proxyEnabled;
  String proxyIPAddress;
  String proxyPort;
  bool proxyAuthenticationEnabled;
  String proxyUsername;
  String proxyPassword;
  bool portScanEnabled;
}