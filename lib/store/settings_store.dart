import 'dart:io';

import 'package:elite_wallet/bitcoin/bitcoin.dart';
import 'package:elite_wallet/entities/elite_2fa_preset_options.dart';
import 'package:elite_wallet/entities/background_tasks.dart';
import 'package:elite_wallet/entities/exchange_api_mode.dart';
import 'package:elite_wallet/entities/pin_code_required_duration.dart';
import 'package:elite_wallet/entities/preferences_key.dart';
import 'package:elite_wallet/entities/sort_balance_types.dart';
import 'package:elite_wallet/view_model/settings/sync_mode.dart';
import 'package:elite_wallet/utils/device_info.dart';
import 'package:elite_wallet/ethereum/ethereum.dart';
import 'package:ew_core/transaction_priority.dart';
import 'package:elite_wallet/themes/theme_base.dart';
import 'package:elite_wallet/themes/theme_list.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info/package_info.dart';
import 'package:elite_wallet/di.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elite_wallet/entities/language_service.dart';
import 'package:elite_wallet/entities/balance_display_mode.dart';
import 'package:elite_wallet/entities/fiat_currency.dart';
import 'package:ew_core/node.dart';
import 'package:elite_wallet/monero/monero.dart';
import 'package:elite_wallet/wownero/wownero.dart';
import 'package:elite_wallet/entities/action_list_display_mode.dart';
import 'package:elite_wallet/entities/fiat_api_mode.dart';
import 'package:ew_core/set_app_secure_native.dart';

part 'settings_store.g.dart';

class SettingsStore = SettingsStoreBase with _$SettingsStore;

abstract class SettingsStoreBase with Store {
  SettingsStoreBase(
      {required BackgroundTasks backgroundTasks,
      required SharedPreferences sharedPreferences,
      required bool initialShouldShowMarketPlaceInDashboard,
      required FiatCurrency initialFiatCurrency,
      required BalanceDisplayMode initialBalanceDisplayMode,
      required bool initialSaveRecipientAddress,
      required bool initialProxyEnabled,
      required String initialProxyIPAddress,
      required String initialProxyPort,
      required bool initialproxyAuthenticationEnabled,
      required String initialProxyUsername,
      required String initialProxyPassword,
      required bool initialPortScanEnabled,
      required bool initialAppSecure,
      required bool initialDisableBuy,
      required bool initialDisableSell,
      required FiatApiMode initialFiatMode,
      required bool initialAllowBiometricalAuthentication,
      required String initialTotpSecretKey,
      required bool initialUseTOTP2FA,
      required int initialFailedTokenTrial,
      required ExchangeApiMode initialExchangeStatus,
      required ThemeBase initialTheme,
      required int initialPinLength,
      required String initialLanguageCode,
      required String initialCryptoPriceProvider,
      required bool initialSelectNodeAutomatically,
      required int initialUserExperience,
      required SyncMode initialSyncMode,
      required bool initialSyncAll,
      // required String initialCurrentLocale,
      required this.appVersion,
      required this.deviceName,
      required Map<WalletType, Node> nodes,
      required this.shouldShowYatPopup,
      required this.isBitcoinBuyEnabled,
      required this.actionlistDisplayMode,
      required this.pinTimeOutDuration,
      required Elite2FAPresetsOptions initialElite2FAPresetOptions,
      required bool initialShouldRequireTOTP2FAForAccessingWallet,
      required bool initialShouldRequireTOTP2FAForSendsToContact,
      required bool initialShouldRequireTOTP2FAForSendsToNonContact,
      required bool initialShouldRequireTOTP2FAForSendsToInternalWallets,
      required bool initialShouldRequireTOTP2FAForExchangesToInternalWallets,
      required bool initialShouldRequireTOTP2FAForAddingContacts,
      required bool initialShouldRequireTOTP2FAForCreatingNewWallets,
      required bool initialShouldRequireTOTP2FAForAllSecurityAndBackupSettings,
      required this.sortBalanceBy,
      required this.pinNativeTokenAtTop,
      required this.useEtherscan,
      TransactionPriority? initialBitcoinTransactionPriority,
      TransactionPriority? initialMoneroTransactionPriority,
      TransactionPriority? initialHavenTransactionPriority,
      TransactionPriority? initialLitecoinTransactionPriority,
      TransactionPriority? initialWowneroTransactionPriority,
      TransactionPriority? initialEthereumTransactionPriority})
      : nodes = ObservableMap<WalletType, Node>.of(nodes),
        proxySettingsListeners = <Function(SettingsStoreBase)>[],
        _sharedPreferences = sharedPreferences,
        _backgroundTasks = backgroundTasks,
        fiatCurrency = initialFiatCurrency,
        balanceDisplayMode = initialBalanceDisplayMode,
        shouldSaveRecipientAddress = initialSaveRecipientAddress,
        proxyEnabled = initialProxyEnabled,
        proxyIPAddress = initialProxyIPAddress,
        proxyPort = initialProxyPort,
        proxyAuthenticationEnabled = initialproxyAuthenticationEnabled,
        proxyUsername = initialProxyUsername,
        proxyPassword = initialProxyPassword,
        portScanEnabled = initialPortScanEnabled,
        fiatApiMode = initialFiatMode,
        allowBiometricalAuthentication = initialAllowBiometricalAuthentication,
        selectedElite2FAPreset = initialElite2FAPresetOptions,
        totpSecretKey = initialTotpSecretKey,
        useTOTP2FA = initialUseTOTP2FA,
        numberOfFailedTokenTrials = initialFailedTokenTrial,
        isAppSecure = initialAppSecure,
        disableBuy = initialDisableBuy,
        disableSell = initialDisableSell,
        shouldShowMarketPlaceInDashboard = initialShouldShowMarketPlaceInDashboard,
        exchangeStatus = initialExchangeStatus,
        currentTheme = initialTheme,
        pinCodeLength = initialPinLength,
        languageCode = initialLanguageCode,
        cryptoPriceProvider = initialCryptoPriceProvider,
        selectNodeAutomatically = initialSelectNodeAutomatically,
        userExperience = initialUserExperience,
        shouldRequireTOTP2FAForAccessingWallet = initialShouldRequireTOTP2FAForAccessingWallet,
        shouldRequireTOTP2FAForSendsToContact = initialShouldRequireTOTP2FAForSendsToContact,
        shouldRequireTOTP2FAForSendsToNonContact = initialShouldRequireTOTP2FAForSendsToNonContact,
        shouldRequireTOTP2FAForSendsToInternalWallets =
            initialShouldRequireTOTP2FAForSendsToInternalWallets,
        shouldRequireTOTP2FAForExchangesToInternalWallets =
            initialShouldRequireTOTP2FAForExchangesToInternalWallets,
        shouldRequireTOTP2FAForAddingContacts = initialShouldRequireTOTP2FAForAddingContacts,
        shouldRequireTOTP2FAForCreatingNewWallets =
            initialShouldRequireTOTP2FAForCreatingNewWallets,
        shouldRequireTOTP2FAForAllSecurityAndBackupSettings =
            initialShouldRequireTOTP2FAForAllSecurityAndBackupSettings,
        currentSyncMode = initialSyncMode,
        currentSyncAll = initialSyncAll,
        priority = ObservableMap<WalletType, TransactionPriority>() {
    //this.nodes = ObservableMap<WalletType, Node>.of(nodes);

    if (initialMoneroTransactionPriority != null) {
      priority[WalletType.monero] = initialMoneroTransactionPriority;
    }

    if (initialBitcoinTransactionPriority != null) {
      priority[WalletType.bitcoin] = initialBitcoinTransactionPriority;
    }

    if (initialHavenTransactionPriority != null) {
      priority[WalletType.haven] = initialHavenTransactionPriority;
    }

    if (initialLitecoinTransactionPriority != null) {
      priority[WalletType.litecoin] = initialLitecoinTransactionPriority;
    }

    if (initialWowneroTransactionPriority != null) {
        priority[WalletType.wownero] = initialWowneroTransactionPriority;
    }

    if (initialEthereumTransactionPriority != null) {
      priority[WalletType.ethereum] = initialEthereumTransactionPriority;
    }

    reaction(
        (_) => fiatCurrency,
        (FiatCurrency fiatCurrency) => sharedPreferences.setString(
            PreferencesKey.currentFiatCurrencyKey, fiatCurrency.serialize()));

    reaction(
        (_) => shouldShowYatPopup,
        (bool shouldShowYatPopup) =>
            sharedPreferences.setBool(PreferencesKey.shouldShowYatPopup, shouldShowYatPopup));

    priority.observe((change) {
      final String? key;
      switch (change.key) {
        case WalletType.monero:
          key = PreferencesKey.moneroTransactionPriority;
          break;
        case WalletType.bitcoin:
          key = PreferencesKey.bitcoinTransactionPriority;
          break;
        case WalletType.litecoin:
          key = PreferencesKey.litecoinTransactionPriority;
          break;
        case WalletType.haven:
          key = PreferencesKey.havenTransactionPriority;
          break;
        case WalletType.wownero:
          key = PreferencesKey.wowneroTransactionPriority;
          break;
        case WalletType.ethereum:
          key = PreferencesKey.ethereumTransactionPriority;
          break;
        default:
          key = null;
      }

      if (change.newValue != null && key != null) {
        sharedPreferences.setInt(key, change.newValue!.serialize());
      }
    });

    reaction(
        (_) => shouldSaveRecipientAddress,
        (bool shouldSaveRecipientAddress) => sharedPreferences.setBool(
            PreferencesKey.shouldSaveRecipientAddressKey, shouldSaveRecipientAddress));

    if (DeviceInfo.instance.isMobile) {
      setIsAppSecureNative(isAppSecure);

      reaction((_) => isAppSecure, (bool isAppSecure) {
        sharedPreferences.setBool(PreferencesKey.isAppSecureKey, isAppSecure);
        setIsAppSecureNative(isAppSecure);
      });
    }

    reaction(
        (_) => proxyEnabled,
        (bool proxyEnabled) {
            sharedPreferences.setBool(
                PreferencesKey.proxyEnabledKey, proxyEnabled);
            _proxySettingsChanged();
        });

    reaction(
        (_) => proxyIPAddress,
        (String proxyIPAddress) {
            sharedPreferences.setString(
                PreferencesKey.proxyIPAddressKey, proxyIPAddress);
            _proxySettingsChanged();
        });

    reaction(
        (_) => proxyPort,
        (String proxyPort) {
            sharedPreferences.setString(
                PreferencesKey.proxyPortKey, proxyPort);
            _proxySettingsChanged();
        });

    reaction(
        (_) => proxyAuthenticationEnabled,
        (bool proxyAuthenticationEnabled) {
            sharedPreferences.setBool(
                PreferencesKey.proxyAuthenticationEnabledKey,
                proxyAuthenticationEnabled);
            _proxySettingsChanged();
        });

    reaction(
        (_) => proxyUsername,
        (String proxyUsername) {
            sharedPreferences.setString(
                PreferencesKey.proxyUsernameKey, proxyUsername);
            _proxySettingsChanged();
        });

    reaction(
        (_) => proxyPassword,
        (String proxyPassword) {
            sharedPreferences.setString(
                PreferencesKey.proxyPasswordKey, proxyPassword);
            _proxySettingsChanged();
        });

    reaction(
        (_) => portScanEnabled,
        (bool portScanEnabled) => sharedPreferences.setBool(
            PreferencesKey.portScanEnabledKey, portScanEnabled));

    reaction((_) => disableBuy,
        (bool disableBuy) => sharedPreferences.setBool(PreferencesKey.disableBuyKey, disableBuy));

    reaction(
        (_) => disableSell,
        (bool disableSell) =>
            sharedPreferences.setBool(PreferencesKey.disableSellKey, disableSell));

    reaction(
        (_) => fiatApiMode,
        (FiatApiMode mode) =>
            sharedPreferences.setInt(PreferencesKey.currentFiatApiModeKey, mode.serialize()));

    reaction((_) => currentTheme,
        (ThemeBase theme) => sharedPreferences.setInt(PreferencesKey.currentTheme, theme.raw));

    reaction(
        (_) => allowBiometricalAuthentication,
        (bool biometricalAuthentication) => sharedPreferences.setBool(
            PreferencesKey.allowBiometricalAuthenticationKey, biometricalAuthentication));

    reaction(
        (_) => selectedElite2FAPreset,
        (Elite2FAPresetsOptions selectedElite2FAPreset) => sharedPreferences.setInt(
            PreferencesKey.selectedElite2FAPreset, selectedElite2FAPreset.serialize()));

    reaction(
        (_) => shouldRequireTOTP2FAForAccessingWallet,
        (bool requireTOTP2FAForAccessingWallet) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForAccessingWallet,
            requireTOTP2FAForAccessingWallet));

    reaction(
        (_) => shouldRequireTOTP2FAForSendsToContact,
        (bool requireTOTP2FAForSendsToContact) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForSendsToContact, requireTOTP2FAForSendsToContact));

    reaction(
        (_) => shouldRequireTOTP2FAForSendsToNonContact,
        (bool requireTOTP2FAForSendsToNonContact) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForSendsToNonContact,
            requireTOTP2FAForSendsToNonContact));

    reaction(
        (_) => shouldRequireTOTP2FAForSendsToInternalWallets,
        (bool requireTOTP2FAForSendsToInternalWallets) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForSendsToInternalWallets,
            requireTOTP2FAForSendsToInternalWallets));

    reaction(
        (_) => shouldRequireTOTP2FAForExchangesToInternalWallets,
        (bool requireTOTP2FAForExchangesToInternalWallets) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForExchangesToInternalWallets,
            requireTOTP2FAForExchangesToInternalWallets));

    reaction(
        (_) => shouldRequireTOTP2FAForAddingContacts,
        (bool requireTOTP2FAForAddingContacts) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForAddingContacts, requireTOTP2FAForAddingContacts));

    reaction(
        (_) => shouldRequireTOTP2FAForCreatingNewWallets,
        (bool requireTOTP2FAForCreatingNewWallets) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForCreatingNewWallets,
            requireTOTP2FAForCreatingNewWallets));

    reaction(
        (_) => shouldRequireTOTP2FAForAllSecurityAndBackupSettings,
        (bool requireTOTP2FAForAllSecurityAndBackupSettings) => sharedPreferences.setBool(
            PreferencesKey.shouldRequireTOTP2FAForAllSecurityAndBackupSettings,
            requireTOTP2FAForAllSecurityAndBackupSettings));

    reaction(
        (_) => useTOTP2FA, (bool use) => sharedPreferences.setBool(PreferencesKey.useTOTP2FA, use));

    reaction(
        (_) => numberOfFailedTokenTrials,
        (int failedTokenTrail) =>
            sharedPreferences.setInt(PreferencesKey.failedTotpTokenTrials, failedTokenTrail));

    reaction((_) => totpSecretKey,
        (String totpKey) => sharedPreferences.setString(PreferencesKey.totpSecretKey, totpKey));

    reaction(
        (_) => shouldShowMarketPlaceInDashboard,
        (bool value) =>
            sharedPreferences.setBool(PreferencesKey.shouldShowMarketPlaceInDashboard, value));

    reaction((_) => pinCodeLength,
        (int pinLength) => sharedPreferences.setInt(PreferencesKey.currentPinLength, pinLength));

    reaction(
        (_) => languageCode,
        (String languageCode) =>
            sharedPreferences.setString(PreferencesKey.currentLanguageCode, languageCode));

    reaction(
        (_) => cryptoPriceProvider,
        (String cryptoPriceProvider) => sharedPreferences.setString(
            PreferencesKey.cryptoPriceProvider, cryptoPriceProvider));

    reaction(
        (_) => pinTimeOutDuration,
        (PinCodeRequiredDuration pinCodeInterval) =>
            sharedPreferences.setInt(PreferencesKey.pinTimeOutDuration, pinCodeInterval.value));

    reaction(
        (_) => selectNodeAutomatically,
        (bool selectNodeAutomatically) => sharedPreferences.setBool(
            PreferencesKey.selectNodeAutomatically, selectNodeAutomatically));

    reaction(
        (_) => userExperience,
        (int userExperience) => sharedPreferences.setInt(
            PreferencesKey.userExperience, userExperience));

    reaction(
        (_) => balanceDisplayMode,
        (BalanceDisplayMode mode) => sharedPreferences.setInt(
            PreferencesKey.currentBalanceDisplayModeKey, mode.serialize()));

    reaction((_) => currentSyncMode, (SyncMode syncMode) {
      sharedPreferences.setInt(PreferencesKey.syncModeKey, syncMode.type.index);

      _backgroundTasks.registerSyncTask(changeExisting: true);
    });

    reaction((_) => currentSyncAll, (bool syncAll) {
      sharedPreferences.setBool(PreferencesKey.syncAllKey, syncAll);

      _backgroundTasks.registerSyncTask(changeExisting: true);
    });

    reaction(
        (_) => exchangeStatus,
        (ExchangeApiMode mode) =>
            sharedPreferences.setInt(PreferencesKey.exchangeStatusKey, mode.serialize()));

    reaction(
        (_) => sortBalanceBy,
        (SortBalanceBy sortBalanceBy) =>
            _sharedPreferences.setInt(PreferencesKey.sortBalanceBy, sortBalanceBy.index));

    reaction(
        (_) => pinNativeTokenAtTop,
        (bool pinNativeTokenAtTop) =>
            _sharedPreferences.setBool(PreferencesKey.pinNativeTokenAtTop, pinNativeTokenAtTop));

    reaction(
        (_) => useEtherscan,
        (bool useEtherscan) =>
            _sharedPreferences.setBool(PreferencesKey.useEtherscan, useEtherscan));

    this.nodes.observe((change) {
      if (change.newValue != null && change.key != null) {
        _saveCurrentNode(change.newValue!, change.key!);
      }
    });
  }

  static const defaultPinLength = 4;
  static const defaultActionsMode = 11;
  static const defaultPinCodeTimeOutDuration = PinCodeRequiredDuration.tenminutes;

  @observable
  FiatCurrency fiatCurrency;

  @observable
  bool shouldShowYatPopup;

  @observable
  bool shouldShowMarketPlaceInDashboard;

  @observable
  ObservableList<ActionListDisplayMode> actionlistDisplayMode;

  @observable
  BalanceDisplayMode balanceDisplayMode;

  @observable
  FiatApiMode fiatApiMode;

  @observable
  bool shouldSaveRecipientAddress;

  @observable
  bool proxyEnabled;

  @observable
  String proxyIPAddress;

  @observable
  String proxyPort;

  @observable
  bool proxyAuthenticationEnabled;

  @observable
  String proxyUsername;

  @observable
  String proxyPassword;

  @observable
  bool portScanEnabled;

  @observable
  bool isAppSecure;

  @observable
  bool disableBuy;

  @observable
  bool disableSell;

  @observable
  bool allowBiometricalAuthentication;

  @observable
  bool shouldRequireTOTP2FAForAccessingWallet;

  @observable
  bool shouldRequireTOTP2FAForSendsToContact;

  @observable
  bool shouldRequireTOTP2FAForSendsToNonContact;

  @observable
  bool shouldRequireTOTP2FAForSendsToInternalWallets;

  @observable
  bool shouldRequireTOTP2FAForExchangesToInternalWallets;

  @observable
  Elite2FAPresetsOptions selectedElite2FAPreset;

  @observable
  bool shouldRequireTOTP2FAForAddingContacts;

  @observable
  bool shouldRequireTOTP2FAForCreatingNewWallets;

  @observable
  bool shouldRequireTOTP2FAForAllSecurityAndBackupSettings;

  @observable
  String totpSecretKey;

  @computed
  String get totpVersionOneLink {
    return 'otpauth://totp/Elite%20Wallet:$deviceName?secret=$totpSecretKey&issuer=Elite%20Wallet&algorithm=SHA512&digits=8&period=30';
  }

  @observable
  bool useTOTP2FA;

  @observable
  int numberOfFailedTokenTrials;

  @observable
  ExchangeApiMode exchangeStatus;

  @observable
  ThemeBase currentTheme;

  @observable
  int pinCodeLength;

  @observable
  PinCodeRequiredDuration pinTimeOutDuration;

  @computed
  ThemeData get theme => currentTheme.themeData;

  @observable
  String languageCode;

  @observable
  String cryptoPriceProvider;

  @observable
  bool selectNodeAutomatically;

  @observable
  int userExperience;

  @observable
  ObservableMap<WalletType, TransactionPriority> priority;

  @observable
  SortBalanceBy sortBalanceBy;

  @observable
  bool pinNativeTokenAtTop;

  @observable
  bool useEtherscan;

  @observable
  SyncMode currentSyncMode;

  @observable
  bool currentSyncAll;

  String appVersion;

  String deviceName;

  final SharedPreferences _sharedPreferences;
  final BackgroundTasks _backgroundTasks;

  ObservableMap<WalletType, Node> nodes;

  List<Function(SettingsStoreBase)> proxySettingsListeners;

  Node getCurrentNode(WalletType walletType) {
    final node = nodes[walletType];

    if (node == null) {
      throw Exception('No node found for wallet type: ${walletType.toString()}');
    }

    return node;
  }

  bool isBitcoinBuyEnabled;

  bool get shouldShowReceiveWarning =>
      _sharedPreferences.getBool(PreferencesKey.shouldShowReceiveWarning) ?? true;

  Future<void> setShouldShowReceiveWarning(bool value) async =>
      _sharedPreferences.setBool(PreferencesKey.shouldShowReceiveWarning, value);

  static Future<SettingsStore> load(
      {required Box<Node> nodeSource,
      required bool isBitcoinBuyEnabled,
      FiatCurrency initialFiatCurrency = FiatCurrency.usd,
      BalanceDisplayMode initialBalanceDisplayMode = BalanceDisplayMode.availableBalance,
      ThemeBase? initialTheme}) async {
    final sharedPreferences = await getIt.getAsync<SharedPreferences>();
    final backgroundTasks = getIt.get<BackgroundTasks>();
    final currentFiatCurrency = FiatCurrency.deserialize(
        raw: sharedPreferences.getString(PreferencesKey.currentFiatCurrencyKey)!);

    TransactionPriority? moneroTransactionPriority = monero?.deserializeMoneroTransactionPriority(
        raw: sharedPreferences.getInt(PreferencesKey.moneroTransactionPriority)!);
    TransactionPriority? bitcoinTransactionPriority =
        bitcoin?.deserializeBitcoinTransactionPriority(
            sharedPreferences.getInt(PreferencesKey.bitcoinTransactionPriority)!);

    TransactionPriority? havenTransactionPriority;
    TransactionPriority? litecoinTransactionPriority;
    TransactionPriority? wowneroTransactionPriority;
    TransactionPriority? ethereumTransactionPriority;

    if (sharedPreferences.getInt(PreferencesKey.havenTransactionPriority) != null) {
      havenTransactionPriority = monero?.deserializeMoneroTransactionPriority(
          raw: sharedPreferences.getInt(PreferencesKey.havenTransactionPriority)!);
    }
    if (sharedPreferences.getInt(PreferencesKey.litecoinTransactionPriority) != null) {
      litecoinTransactionPriority = bitcoin?.deserializeLitecoinTransactionPriority(
          sharedPreferences.getInt(PreferencesKey.litecoinTransactionPriority)!);
    }
    if (sharedPreferences.getInt(PreferencesKey.wowneroTransactionPriority) != null) {
      wowneroTransactionPriority = wownero?.deserializeMoneroTransactionPriority(
          raw: sharedPreferences.getInt(PreferencesKey.wowneroTransactionPriority)!);
    }

    if (sharedPreferences.getInt(PreferencesKey.ethereumTransactionPriority) != null) {
      ethereumTransactionPriority = bitcoin?.deserializeLitecoinTransactionPriority(
          sharedPreferences.getInt(PreferencesKey.ethereumTransactionPriority)!);
    }

    moneroTransactionPriority ??= monero?.getDefaultTransactionPriority();
    bitcoinTransactionPriority ??= bitcoin?.getMediumTransactionPriority();
    havenTransactionPriority ??= monero?.getDefaultTransactionPriority();
    litecoinTransactionPriority ??= bitcoin?.getLitecoinTransactionPriorityMedium();
    wowneroTransactionPriority ??= wownero?.getDefaultTransactionPriority();
    ethereumTransactionPriority ??= ethereum?.getDefaultTransactionPriority();

    final currentBalanceDisplayMode = BalanceDisplayMode.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.currentBalanceDisplayModeKey)!);
    // FIX-ME: Check for which default value we should have here
    final shouldSaveRecipientAddress =
        sharedPreferences.getBool(PreferencesKey.shouldSaveRecipientAddressKey) ?? false;
    final proxyEnabled =
        sharedPreferences.getBool(PreferencesKey.proxyEnabledKey) ?? true;
    final proxyIPAddress =
        sharedPreferences.getString(PreferencesKey.proxyIPAddressKey) ?? "";
    final proxyPort =
        sharedPreferences.getString(PreferencesKey.proxyPortKey) ?? "";
    final proxyAuthenticationEnabled =
        sharedPreferences.getBool(PreferencesKey.proxyAuthenticationEnabledKey)
        ?? false;
    final proxyUsername =
        sharedPreferences.getString(PreferencesKey.proxyUsernameKey) ?? "";
    final proxyPassword =
        sharedPreferences.getString(PreferencesKey.proxyPasswordKey) ?? "";
    final portScanEnabled =
        sharedPreferences.getBool(PreferencesKey.portScanEnabledKey) ?? false;
    final isAppSecure = sharedPreferences.getBool(PreferencesKey.isAppSecureKey) ?? false;
    final disableBuy = sharedPreferences.getBool(PreferencesKey.disableBuyKey) ?? false;
    final disableSell = sharedPreferences.getBool(PreferencesKey.disableSellKey) ?? false;
    final currentFiatApiMode = FiatApiMode.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.currentFiatApiModeKey) ??
            FiatApiMode.enabled.raw);
    final allowBiometricalAuthentication =
        sharedPreferences.getBool(PreferencesKey.allowBiometricalAuthenticationKey) ?? false;
    final selectedElite2FAPreset = Elite2FAPresetsOptions.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.selectedElite2FAPreset) ??
            Elite2FAPresetsOptions.normal.raw);
    final shouldRequireTOTP2FAForAccessingWallet =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForAccessingWallet) ?? false;
    final shouldRequireTOTP2FAForSendsToContact =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForSendsToContact) ?? false;
    final shouldRequireTOTP2FAForSendsToNonContact =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForSendsToNonContact) ?? false;
    final shouldRequireTOTP2FAForSendsToInternalWallets =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForSendsToInternalWallets) ??
            false;
    final shouldRequireTOTP2FAForExchangesToInternalWallets = sharedPreferences
            .getBool(PreferencesKey.shouldRequireTOTP2FAForExchangesToInternalWallets) ??
        false;
    final shouldRequireTOTP2FAForAddingContacts =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForAddingContacts) ?? false;
    final shouldRequireTOTP2FAForCreatingNewWallets =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForCreatingNewWallets) ??
            false;
    final shouldRequireTOTP2FAForAllSecurityAndBackupSettings = sharedPreferences
            .getBool(PreferencesKey.shouldRequireTOTP2FAForAllSecurityAndBackupSettings) ??
        false;
    final totpSecretKey = sharedPreferences.getString(PreferencesKey.totpSecretKey) ?? '';
    final useTOTP2FA = sharedPreferences.getBool(PreferencesKey.useTOTP2FA) ?? false;
    final tokenTrialNumber = sharedPreferences.getInt(PreferencesKey.failedTotpTokenTrials) ?? 0;
    final shouldShowMarketPlaceInDashboard =
        sharedPreferences.getBool(PreferencesKey.shouldShowMarketPlaceInDashboard) ?? false;
    final exchangeStatus = ExchangeApiMode.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.exchangeStatusKey) ??
            ExchangeApiMode.enabled.raw);
    final savedTheme = ThemeList.deserialize(raw: ThemeType.dark.index);
    final actionListDisplayMode = ObservableList<ActionListDisplayMode>();
    actionListDisplayMode.addAll(deserializeActionlistDisplayModes(
        sharedPreferences.getInt(PreferencesKey.displayActionListModeKey) ?? defaultActionsMode));
    var pinLength = sharedPreferences.getInt(PreferencesKey.currentPinLength);
    final timeOutDuration = sharedPreferences.getInt(PreferencesKey.pinTimeOutDuration);
    final pinCodeTimeOutDuration = timeOutDuration != null
        ? PinCodeRequiredDuration.deserialize(raw: timeOutDuration)
        : defaultPinCodeTimeOutDuration;
    final sortBalanceBy =
        SortBalanceBy.values[sharedPreferences.getInt(PreferencesKey.sortBalanceBy) ?? 0];
    final pinNativeTokenAtTop =
        sharedPreferences.getBool(PreferencesKey.pinNativeTokenAtTop) ?? true;
    final useEtherscan =
        sharedPreferences.getBool(PreferencesKey.useEtherscan) ?? true;

    // If no value
    if (pinLength == null || pinLength == 0) {
      pinLength = defaultPinLength;
    }

    final savedLanguageCode = sharedPreferences.getString(PreferencesKey.currentLanguageCode) ??
        await LanguageService.localeDetection();
    final savedCryptoPriceProvider =
        sharedPreferences.getString(PreferencesKey.cryptoPriceProvider) ??
            "CoinGecko";
    final savedSelectNodeAutomatically =
        sharedPreferences.getBool(PreferencesKey.selectNodeAutomatically) ??
            true;
    final savedUserExperience =
        sharedPreferences.getInt(PreferencesKey.userExperience) ?? 0;
    final nodeId = sharedPreferences.getInt(PreferencesKey.currentNodeIdKey);
    final bitcoinElectrumServerId =
        sharedPreferences.getInt(PreferencesKey.currentBitcoinElectrumSererIdKey);
    final litecoinElectrumServerId =
        sharedPreferences.getInt(PreferencesKey.currentLitecoinElectrumSererIdKey);
    final havenNodeId = sharedPreferences.getInt(PreferencesKey.currentHavenNodeIdKey);
    final wowneroNodeId =
        sharedPreferences.getInt(PreferencesKey.currentWowneroNodeIdKey);
    final ethereumNodeId = sharedPreferences.getInt(PreferencesKey.currentEthereumNodeIdKey);
    final moneroNode = nodeSource.get(nodeId);
    final bitcoinElectrumServer = nodeSource.get(bitcoinElectrumServerId);
    final litecoinElectrumServer = nodeSource.get(litecoinElectrumServerId);
    final havenNode = nodeSource.get(havenNodeId);
    final wowneroNode = nodeSource.get(wowneroNodeId);
    final ethereumNode = nodeSource.get(ethereumNodeId);
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceName = await _getDeviceName() ?? '';
    final shouldShowYatPopup = sharedPreferences.getBool(PreferencesKey.shouldShowYatPopup) ?? true;

    final nodes = <WalletType, Node>{};

    if (moneroNode != null) {
      nodes[WalletType.monero] = moneroNode;
    }

    if (bitcoinElectrumServer != null) {
      nodes[WalletType.bitcoin] = bitcoinElectrumServer;
    }

    if (litecoinElectrumServer != null) {
      nodes[WalletType.litecoin] = litecoinElectrumServer;
    }

    if (havenNode != null) {
      nodes[WalletType.haven] = havenNode;
    }

    if (wowneroNode != null) {
        nodes[WalletType.wownero] = wowneroNode;
    }

    if (ethereumNode != null) {
      nodes[WalletType.ethereum] = ethereumNode;
    }

    final savedSyncMode = SyncMode.all.firstWhere((element) {
      return element.type.index == (sharedPreferences.getInt(PreferencesKey.syncModeKey) ?? 1);
    });
    final savedSyncAll = sharedPreferences.getBool(PreferencesKey.syncAllKey) ?? true;

    return SettingsStore(
        sharedPreferences: sharedPreferences,
        initialShouldShowMarketPlaceInDashboard: shouldShowMarketPlaceInDashboard,
        nodes: nodes,
        appVersion: packageInfo.version,
        deviceName: deviceName,
        isBitcoinBuyEnabled: isBitcoinBuyEnabled,
        initialFiatCurrency: currentFiatCurrency,
        initialBalanceDisplayMode: currentBalanceDisplayMode,
        initialSaveRecipientAddress: shouldSaveRecipientAddress,
        initialProxyEnabled: proxyEnabled,
        initialProxyIPAddress: proxyIPAddress,
        initialProxyPort: proxyPort,
        initialproxyAuthenticationEnabled: proxyAuthenticationEnabled,
        initialProxyUsername: proxyUsername,
        initialProxyPassword: proxyPassword,
        initialPortScanEnabled: portScanEnabled,
        initialAppSecure: isAppSecure,
        initialDisableBuy: disableBuy,
        initialDisableSell: disableSell,
        initialFiatMode: currentFiatApiMode,
        initialAllowBiometricalAuthentication: allowBiometricalAuthentication,
        initialElite2FAPresetOptions: selectedElite2FAPreset,
        initialTotpSecretKey: totpSecretKey,
        initialUseTOTP2FA: useTOTP2FA,
        initialFailedTokenTrial: tokenTrialNumber,
        initialExchangeStatus: exchangeStatus,
        initialTheme: savedTheme,
        actionlistDisplayMode: actionListDisplayMode,
        initialPinLength: pinLength,
        pinTimeOutDuration: pinCodeTimeOutDuration,
        initialLanguageCode: savedLanguageCode,
        initialCryptoPriceProvider: savedCryptoPriceProvider,
        initialSelectNodeAutomatically: savedSelectNodeAutomatically,
        initialUserExperience: savedUserExperience,
        sortBalanceBy: sortBalanceBy,
        pinNativeTokenAtTop: pinNativeTokenAtTop,
        useEtherscan: useEtherscan,
        initialMoneroTransactionPriority: moneroTransactionPriority,
        initialBitcoinTransactionPriority: bitcoinTransactionPriority,
        initialHavenTransactionPriority: havenTransactionPriority,
        initialLitecoinTransactionPriority: litecoinTransactionPriority,
        initialWowneroTransactionPriority: wowneroTransactionPriority,
        initialShouldRequireTOTP2FAForAccessingWallet: shouldRequireTOTP2FAForAccessingWallet,
        initialShouldRequireTOTP2FAForSendsToContact: shouldRequireTOTP2FAForSendsToContact,
        initialShouldRequireTOTP2FAForSendsToNonContact: shouldRequireTOTP2FAForSendsToNonContact,
        initialShouldRequireTOTP2FAForSendsToInternalWallets:
            shouldRequireTOTP2FAForSendsToInternalWallets,
        initialShouldRequireTOTP2FAForExchangesToInternalWallets:
            shouldRequireTOTP2FAForExchangesToInternalWallets,
        initialShouldRequireTOTP2FAForAddingContacts: shouldRequireTOTP2FAForAddingContacts,
        initialShouldRequireTOTP2FAForCreatingNewWallets: shouldRequireTOTP2FAForCreatingNewWallets,
        initialShouldRequireTOTP2FAForAllSecurityAndBackupSettings:
            shouldRequireTOTP2FAForAllSecurityAndBackupSettings,
        initialEthereumTransactionPriority: ethereumTransactionPriority,
        backgroundTasks: backgroundTasks,
        initialSyncMode: savedSyncMode,
        initialSyncAll: savedSyncAll,
        shouldShowYatPopup: shouldShowYatPopup);
  }

  Future<void> reload({required Box<Node> nodeSource}) async {
    final sharedPreferences = await getIt.getAsync<SharedPreferences>();

    fiatCurrency = FiatCurrency.deserialize(
        raw: sharedPreferences.getString(PreferencesKey.currentFiatCurrencyKey)!);

    priority[WalletType.monero] = monero?.deserializeMoneroTransactionPriority(
            raw: sharedPreferences.getInt(PreferencesKey.moneroTransactionPriority)!) ??
        priority[WalletType.monero]!;
    priority[WalletType.bitcoin] = bitcoin?.deserializeBitcoinTransactionPriority(
            sharedPreferences.getInt(PreferencesKey.moneroTransactionPriority)!) ??
        priority[WalletType.bitcoin]!;

    if (sharedPreferences.getInt(PreferencesKey.havenTransactionPriority) != null) {
      priority[WalletType.haven] = monero?.deserializeMoneroTransactionPriority(
              raw: sharedPreferences.getInt(PreferencesKey.havenTransactionPriority)!) ??
          priority[WalletType.haven]!;
    }
    if (sharedPreferences.getInt(PreferencesKey.litecoinTransactionPriority) != null) {
      priority[WalletType.litecoin] = bitcoin?.deserializeLitecoinTransactionPriority(
              sharedPreferences.getInt(PreferencesKey.litecoinTransactionPriority)!) ??
          priority[WalletType.litecoin]!;
    }
    if (sharedPreferences.getInt(PreferencesKey.wowneroTransactionPriority) != null) {
      priority[WalletType.wownero] = wownero?.deserializeMoneroTransactionPriority(
              raw: sharedPreferences.getInt(PreferencesKey.wowneroTransactionPriority)!) ??
          priority[WalletType.wownero]!;
    }

    if (sharedPreferences.getInt(PreferencesKey.ethereumTransactionPriority) != null) {
      priority[WalletType.ethereum] = ethereum?.deserializeEthereumTransactionPriority(
              sharedPreferences.getInt(PreferencesKey.ethereumTransactionPriority)!) ??
          priority[WalletType.ethereum]!;
    }

    balanceDisplayMode = BalanceDisplayMode.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.currentBalanceDisplayModeKey)!);
    shouldSaveRecipientAddress =
        sharedPreferences.getBool(PreferencesKey.shouldSaveRecipientAddressKey) ??
            shouldSaveRecipientAddress;
    totpSecretKey = sharedPreferences.getString(PreferencesKey.totpSecretKey) ?? totpSecretKey;
    useTOTP2FA = sharedPreferences.getBool(PreferencesKey.useTOTP2FA) ?? useTOTP2FA;

    numberOfFailedTokenTrials =
        sharedPreferences.getInt(PreferencesKey.failedTotpTokenTrials) ?? numberOfFailedTokenTrials;
    sharedPreferences.getBool(PreferencesKey.shouldSaveRecipientAddressKey) ??
        shouldSaveRecipientAddress;
    isAppSecure = sharedPreferences.getBool(PreferencesKey.isAppSecureKey) ?? isAppSecure;
    disableBuy = sharedPreferences.getBool(PreferencesKey.disableBuyKey) ?? disableBuy;
    disableSell = sharedPreferences.getBool(PreferencesKey.disableSellKey) ?? disableSell;
    allowBiometricalAuthentication =
        sharedPreferences.getBool(PreferencesKey.allowBiometricalAuthenticationKey) ??
            allowBiometricalAuthentication;
    selectedElite2FAPreset = Elite2FAPresetsOptions.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.selectedElite2FAPreset) ??
            Elite2FAPresetsOptions.normal.raw);
    shouldRequireTOTP2FAForAccessingWallet =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForAccessingWallet) ?? false;
    shouldRequireTOTP2FAForSendsToContact =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForSendsToContact) ?? false;
    shouldRequireTOTP2FAForSendsToNonContact =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForSendsToNonContact) ?? false;
    shouldRequireTOTP2FAForSendsToInternalWallets =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForSendsToInternalWallets) ??
            false;
    shouldRequireTOTP2FAForExchangesToInternalWallets = sharedPreferences
            .getBool(PreferencesKey.shouldRequireTOTP2FAForExchangesToInternalWallets) ??
        false;
    shouldRequireTOTP2FAForAddingContacts =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForAddingContacts) ?? false;
    shouldRequireTOTP2FAForCreatingNewWallets =
        sharedPreferences.getBool(PreferencesKey.shouldRequireTOTP2FAForCreatingNewWallets) ??
            false;
    shouldRequireTOTP2FAForAllSecurityAndBackupSettings = sharedPreferences
            .getBool(PreferencesKey.shouldRequireTOTP2FAForAllSecurityAndBackupSettings) ??
        false;
    shouldShowMarketPlaceInDashboard =
        sharedPreferences.getBool(PreferencesKey.shouldShowMarketPlaceInDashboard) ??
            shouldShowMarketPlaceInDashboard;
    selectedElite2FAPreset = Elite2FAPresetsOptions.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.selectedElite2FAPreset) ??
            Elite2FAPresetsOptions.narrow.raw);
    exchangeStatus = ExchangeApiMode.deserialize(
        raw: sharedPreferences.getInt(PreferencesKey.exchangeStatusKey) ??
            ExchangeApiMode.enabled.raw);
    currentTheme = ThemeList.deserialize(raw: ThemeType.dark.index);
    actionlistDisplayMode = ObservableList<ActionListDisplayMode>();
    actionlistDisplayMode.addAll(deserializeActionlistDisplayModes(
        sharedPreferences.getInt(PreferencesKey.displayActionListModeKey) ?? defaultActionsMode));
    var pinLength = sharedPreferences.getInt(PreferencesKey.currentPinLength);
    // If no value
    if (pinLength == null || pinLength == 0) {
      pinLength = pinCodeLength;
    }
    pinCodeLength = pinLength;

    languageCode = sharedPreferences.getString(PreferencesKey.currentLanguageCode) ?? languageCode;
    shouldShowYatPopup =
        sharedPreferences.getBool(PreferencesKey.shouldShowYatPopup) ?? shouldShowYatPopup;
    sortBalanceBy = SortBalanceBy
        .values[sharedPreferences.getInt(PreferencesKey.sortBalanceBy) ?? sortBalanceBy.index];
    pinNativeTokenAtTop = sharedPreferences.getBool(PreferencesKey.pinNativeTokenAtTop) ?? true;
    useEtherscan = sharedPreferences.getBool(PreferencesKey.useEtherscan) ?? true;

    final nodeId = sharedPreferences.getInt(PreferencesKey.currentNodeIdKey);
    final bitcoinElectrumServerId =
        sharedPreferences.getInt(PreferencesKey.currentBitcoinElectrumSererIdKey);
    final litecoinElectrumServerId =
        sharedPreferences.getInt(PreferencesKey.currentLitecoinElectrumSererIdKey);
    final havenNodeId = sharedPreferences.getInt(PreferencesKey.currentHavenNodeIdKey);
    final wowneroNodeId = sharedPreferences
        .getInt(PreferencesKey.currentWowneroNodeIdKey);
    final ethereumNodeId = sharedPreferences.getInt(PreferencesKey.currentEthereumNodeIdKey);
    final moneroNode = nodeSource.get(nodeId);
    final bitcoinElectrumServer = nodeSource.get(bitcoinElectrumServerId);
    final litecoinElectrumServer = nodeSource.get(litecoinElectrumServerId);
    final havenNode = nodeSource.get(havenNodeId);
    final wowneroNode = nodeSource.get(wowneroNodeId);
    final ethereumNode = nodeSource.get(ethereumNodeId);

    if (moneroNode != null) {
      nodes[WalletType.monero] = moneroNode;
    }

    if (bitcoinElectrumServer != null) {
      nodes[WalletType.bitcoin] = bitcoinElectrumServer;
    }

    if (litecoinElectrumServer != null) {
      nodes[WalletType.litecoin] = litecoinElectrumServer;
    }

    if (havenNode != null) {
      nodes[WalletType.haven] = havenNode;
    }

    if (wowneroNode != null) {
      nodes[WalletType.wownero] = wowneroNode;
    }

    if (ethereumNode != null) {
      nodes[WalletType.ethereum] = ethereumNode;
    }
  }

  Future<void> _saveCurrentNode(Node node, WalletType walletType) async {
    switch (walletType) {
      case WalletType.bitcoin:
        await _sharedPreferences.setInt(
            PreferencesKey.currentBitcoinElectrumSererIdKey, node.key as int);
        break;
      case WalletType.litecoin:
        await _sharedPreferences.setInt(
            PreferencesKey.currentLitecoinElectrumSererIdKey, node.key as int);
        break;
      case WalletType.monero:
        await _sharedPreferences.setInt(PreferencesKey.currentNodeIdKey, node.key as int);
        break;
      case WalletType.haven:
        await _sharedPreferences.setInt(PreferencesKey.currentHavenNodeIdKey, node.key as int);
        break;
      case WalletType.wownero:
        await _sharedPreferences.setInt(
            PreferencesKey.currentWowneroNodeIdKey, node.key as int);
        break;
      case WalletType.ethereum:
        await _sharedPreferences.setInt(PreferencesKey.currentEthereumNodeIdKey, node.key as int);
        break;
      default:
        break;
    }

    nodes[walletType] = node;
  }

  void _proxySettingsChanged() {
    for (var proxySettingsListener in proxySettingsListeners) {
      proxySettingsListener(this);
    }
  }

  static Future<String?> _getDeviceName() async {
    String? deviceName = '';
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceName = '${androidInfo.brand}%20${androidInfo.manufacturer}%20${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceName = iosInfo.model;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfoPlugin.linuxInfo;
      deviceName = linuxInfo.prettyName;
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfoPlugin.macOsInfo;
      deviceName = macInfo.computerName;
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfoPlugin.windowsInfo;
      deviceName = windowsInfo.productName;
    }

    return deviceName;
  }
}
