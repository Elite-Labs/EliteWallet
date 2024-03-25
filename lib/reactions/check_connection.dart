import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/sync_status.dart';
import 'package:elite_wallet/di.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/node.dart';
import 'package:hive/hive.dart';

Timer? _checkConnectionTimer;
final Duration changeNodeTimeout = Duration(seconds: 20);
final Duration timeInterval = Duration(seconds: 5);
Duration timeSinceLastSync = Duration();

void startCheckConnectionReaction(
    WalletBase wallet, SettingsStore settingsStore) {
  _checkConnectionTimer?.cancel();
  _checkConnectionTimer =
    Timer.periodic(
      timeInterval, (_) => { checkConnection(wallet, settingsStore) });
}

void checkConnection(WalletBase wallet, SettingsStore settingsStore) async {
  try {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      wallet.syncStatus = FailedSyncStatus();
      return;
    }

    if (wallet.syncStatus is ConnectedSyncStatus ||
        wallet.syncStatus is SyncedSyncStatus ||
        wallet.syncStatus is SyncingSyncStatus) {
      timeSinceLastSync = Duration();
    } else {
      timeSinceLastSync += timeInterval;
    }

    if (timeSinceLastSync >= changeNodeTimeout &&
        settingsStore.selectNodeAutomatically) {
      List<Node> nodes = getIt.get<Box<Node>>().values.toList();
      nodes.removeWhere((val) => val.type != wallet.type);
      settingsStore.nodes[wallet.type] = nodes[Random().nextInt(nodes.length)];
      timeSinceLastSync = Duration();
    }

    if (wallet.syncStatus is LostConnectionSyncStatus ||
        wallet.syncStatus is FailedSyncStatus) {
      final alive =
          await settingsStore.getCurrentNode(wallet.type).requestNode();

      if (alive) {
        await wallet.connectToNode(
            node: settingsStore.getCurrentNode(wallet.type));
      }
    }
  } catch (e) {
    print(e.toString());
  }
}
