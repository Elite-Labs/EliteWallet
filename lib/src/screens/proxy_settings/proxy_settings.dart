import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/view_model/proxy_settings/proxy_input_list_item.dart';
import 'package:elite_wallet/view_model/proxy_settings/proxy_settings_view_model.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';
import 'package:elite_wallet/view_model/proxy_settings/switcher_list_item.dart';
import 'package:elite_wallet/view_model/proxy_settings/save_button_list_item.dart';
import 'package:elite_wallet/src/screens/proxy_settings/widgets/settings_proxy_input_cell.dart';
import 'package:elite_wallet/src/screens/proxy_settings/widgets/settings_switcher_cell.dart';
import 'package:elite_wallet/src/widgets/alert_with_two_actions.dart';
import 'package:elite_wallet/src/widgets/primary_button.dart';
import 'package:elite_wallet/src/widgets/standard_list.dart';
import 'package:elite_wallet/src/screens/base_page.dart';
import 'package:elite_wallet/utils/show_pop_up.dart';
import 'package:ew_core/port_redirector.dart';
import 'package:ew_core/proxy_settings_store.dart';

class ProxySettingsPage extends BasePage {
  ProxySettingsPage(this.proxySettingsViewModel,
                    this.additionalItems)
    : _withoutValidityCheck = !additionalItems.isEmpty;

  final ProxySettingsViewModel proxySettingsViewModel;
  
  final List<List<SettingsListItem>> additionalItems;

  final bool _withoutValidityCheck;

  @override
  String get title => S.current.settings_proxy_settings;

  static bool isCheckingValidity = false;

  static Future<void> showPopupIfInvalid(
    BuildContext context, ProxySettingsStore proxy,
    void Function() action) async {
    if (isCheckingValidity) {
      return;
    }
    isCheckingValidity = true;
    bool isProxyValid = await PortRedirector.isProxyValid(proxy);
    isCheckingValidity = false;

    if (isProxyValid) {
      action();
    } else {
      showPopUp<void>(
        context: context,
        builder: (dialogContext) {
          return AlertWithTwoActions(
              alertTitle:
                  S.of(context).node_connection_failed,
              alertContent: S
                  .of(context)
                  .proxy_failed_alert,
              rightButtonText:
                  S.of(context).ok,
              leftButtonText:
                  S.of(context).cancel,
              actionRightButton: () {
                Navigator.of(dialogContext).pop();
                action();
              },
              actionLeftButton: () => Navigator.of(dialogContext).pop());
        },
      );
    }
  }

  @override
  void onClose(BuildContext context) async {
    void Function() close = () {
      proxySettingsViewModel.reconnect();
      Navigator.of(context).pop();
    };
    if (_withoutValidityCheck) {
      close();
    } else {
      showPopupIfInvalid(
        context, proxySettingsViewModel.proxySettingsStore, close);
    }
  }

  @override
  Widget body(BuildContext context) {
    if (additionalItems != null) {
      for (var item in additionalItems) {
        proxySettingsViewModel.sections.add(item);
      }
    }

    return SectionStandardList(
        sectionCount: proxySettingsViewModel.sections.length,
        context: context,
        itemCounter: (int sectionIndex) {
          if (sectionIndex < proxySettingsViewModel.sections.length) {
            return proxySettingsViewModel.sections[sectionIndex].length;
          }

          return 0;
        },
        itemBuilder: (_, sectionIndex, itemIndex) {
          final item = 
            proxySettingsViewModel.sections[sectionIndex][itemIndex];
          if (item is ProxyInputListItem) {
            return Observer(builder: (_) {
              return SettingsProxyInputCell(
                type: item.type,
                value: item.value(),
                onValueChange: item.onValueChange,
                enabled: item.enabled(),
              );
            });
          }

          if (item is SwitcherListItem) {
            return Observer(builder: (_) {
              return SettingsSwitcherCell(
                  title: item.title,
                  value: item.value(),
                  onValueChange: item.onValueChange);
            });
          }

          if (item is SaveButtonistItem) {
            return Observer(builder: (_) {
              return LoadingPrimaryButton(
                onPressed: () => item.navigateTo(),
                isLoading: item.isLoading,
                text: S.of(context).save,
                color: Theme.of(context)
                    .accentTextTheme
                    .bodyText1!
                    .color!,
                textColor: Colors.white);
            });
          }

          return Container();
        });
  }
}
