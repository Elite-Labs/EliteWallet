import 'dart:async';
import 'package:elite_wallet/reactions/fiat_rate_update.dart';
import 'package:elite_wallet/reactions/on_current_fiat_api_mode_change.dart';
import 'package:elite_wallet/reactions/on_current_node_change.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elite_wallet/di.dart';
import 'package:elite_wallet/entities/preferences_key.dart';
import 'package:elite_wallet/reactions/on_authentication_state_change.dart';
import 'package:elite_wallet/reactions/on_current_fiat_change.dart';
import 'package:elite_wallet/reactions/on_current_wallet_change.dart';
import 'package:elite_wallet/store/app_store.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/store/authentication_store.dart';
import 'package:elite_wallet/store/dashboard/fiat_conversion_store.dart';

Future<void> bootstrap(GlobalKey<NavigatorState> navigatorKey) async {
  final appStore = getIt.get<AppStore>();
  final authenticationStore = getIt.get<AuthenticationStore>();
  final settingsStore = getIt.get<SettingsStore>();
  final fiatConversionStore = getIt.get<FiatConversionStore>();

  final currentWalletName = getIt
      .get<SharedPreferences>()
      .getString(PreferencesKey.currentWalletName);
  if (currentWalletName != null) {
    authenticationStore.installed();
  }
  ++settingsStore.userExperience;

  startAuthenticationStateChange(authenticationStore, navigatorKey);
  startCurrentWalletChangeReaction(
      appStore, settingsStore, fiatConversionStore);
  startCurrentFiatChangeReaction(appStore, settingsStore, fiatConversionStore);
  startCurrentFiatApiModeChangeReaction(appStore, settingsStore, fiatConversionStore);
  startOnCurrentNodeChangeReaction(appStore);
  startFiatRateUpdate(appStore, settingsStore, fiatConversionStore);
}
