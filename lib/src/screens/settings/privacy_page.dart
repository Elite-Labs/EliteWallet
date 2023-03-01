import 'package:elite_wallet/core/fiat_conversion_service.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/routes.dart';
import 'package:elite_wallet/src/screens/base_page.dart';
import 'package:elite_wallet/src/screens/settings/widgets/settings_cell_with_arrow.dart';
import 'package:elite_wallet/src/screens/settings/widgets/settings_picker_cell.dart';
import 'package:elite_wallet/src/screens/settings/widgets/settings_switcher_cell.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';
import 'package:elite_wallet/view_model/settings/privacy_settings_view_model.dart';
import 'package:elite_wallet/view_model/settings/regular_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class PrivacyPage extends BasePage {
  PrivacyPage(this._privacySettingsViewModel);

  @override
  String get title => S.current.privacy_settings;

  final PrivacySettingsViewModel _privacySettingsViewModel;

  @override
  Widget body(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Observer(builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsSwitcherCell(
                title: S.current.disable_fiat,
                value: _privacySettingsViewModel.isFiatDisabled,
                onValueChange: (BuildContext context, bool value) {
                  _privacySettingsViewModel.setFiatMode(value);
                }),
              SettingsSwitcherCell(
                  title: S.current.disable_exchange,
                  value: _privacySettingsViewModel.disableExchange,
                  onValueChange: (BuildContext context, bool value) {
                    _privacySettingsViewModel.setEnableExchange(value);
                  }),
              SettingsSwitcherCell(
                  title: S.current.settings_save_recipient_address,
                  value: _privacySettingsViewModel.shouldSaveRecipientAddress,
                  onValueChange: (BuildContext _, bool value) {
                    _privacySettingsViewModel.setShouldSaveRecipientAddress(value);
                  }),
              SettingsCellWithArrow(
                title: S.current.settings_proxy_settings,
                handler: (BuildContext context) =>
                  Navigator.of(context).pushNamed(
                    Routes.proxySettings,
                    arguments: <List<SettingsListItem>>[])),
              SettingsPickerCell<String>(
                title: S.current.settings_crypto_price_provider,
                items: FiatConversionService.services,
                displayItem: (dynamic service) {
                  return service;
                },
                selectedItem:
                  _privacySettingsViewModel.settingsStore.cryptoPriceProvider,
                onItemSelected: (String provider) {
                  _privacySettingsViewModel.settingsStore.cryptoPriceProvider =
                    provider;
                },
                matchingCriteria: (String service, String searchText) {
                  return service.toLowerCase().contains(searchText);
                },
              ),
            ],
          );
      }),
    );
  }
}
