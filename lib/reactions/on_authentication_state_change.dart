import 'package:elite_wallet/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/entities/load_current_wallet.dart';
import 'package:elite_wallet/store/authentication_store.dart';

ReactionDisposer? _onAuthenticationStateChange;

dynamic loginError;

void startAuthenticationStateChange(AuthenticationStore authenticationStore,
    GlobalKey<NavigatorState> navigatorKey) {
  _onAuthenticationStateChange ??= autorun((_) async {
    final state = authenticationStore.state;

    if (state == AuthenticationState.installed) {
      try {
        await loadCurrentWallet();
      } catch (e) {
        loginError = e;
      }
      return;
    }

    if (state == AuthenticationState.allowed) {
      await navigatorKey.currentState!.pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
      return;
    }
  });
}
