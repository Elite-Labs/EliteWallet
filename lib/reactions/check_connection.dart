import 'dart:async';

import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/sync_status.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:connectivity/connectivity.dart';

Timer? _checkConnectionTimer;

void startCheckConnectionReaction(
    WalletBase wallet, SettingsStore settingsStore,
    {int timeInterval = 5}) {
  _checkConnectionTimer?.cancel();
  _checkConnectionTimer =
      Timer.periodic(Duration(seconds: timeInterval), (_) async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        wallet.syncStatus = FailedSyncStatus();
        return;
      }

      if (wallet.syncStatus is LostConnectionSyncStatus ||
          wallet.syncStatus is FailedSyncStatus) {
        final alive =
            await settingsStore.getCurrentNode(wallet.type).requestNode(
                settingsStore);

        if (alive) {
          await wallet.connectToNode(
              node: settingsStore.getCurrentNode(wallet.type),
              settingsStore: settingsStore);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  });
}
