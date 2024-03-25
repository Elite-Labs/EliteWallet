import 'package:elite_wallet/themes/theme_base.dart';
import 'package:flutter/material.dart';
import 'package:elite_wallet/routes.dart';
import 'package:elite_wallet/src/widgets/primary_button.dart';
import 'package:elite_wallet/src/screens/base_page.dart';
import 'package:elite_wallet/src/screens/proxy_settings/proxy_settings.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/view_model/proxy_settings/save_button_list_item.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';
import 'package:elite_wallet/wallet_type_utils.dart';
import 'package:ew_core/proxy_settings_store.dart';

class SelectAnonymityPage extends BasePage {
  SelectAnonymityPage(this.settingsStore, this.fromWelcome);

  static const aspectRatioImage = 1.25;
  final welcomeImage = Image.asset('assets/images/elitewallet_logo.png');
  SettingsStore settingsStore;
  bool fromWelcome;

  @override
  String get title => fromWelcome ? "" : S.current.settings_select_anonymity;

  String appDescription(BuildContext context) {
    if (isMoneroOnly) {
      return S.of(context).monero_sc_wallet_text;
    }

    if (isHaven) {
      return S.of(context).haven_app_wallet_text;
    }

    if (isWownero) {
      return S.of(context).wownero_app_wallet_text;
    }
    
    return S.of(context).first_wallet_text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: body(context));
  }

  @override
  Widget body(BuildContext context) {

    final standardAnonymity = Image.asset(
        'assets/images/standard_anonymity.png',
        height: 32,
        width: 32);
    final advancedAnonymity = Image.asset(
        'assets/images/advanced_anonymity.png',
        height: 32,
        width: 32);
    final eliteAnonymity = Image.asset('assets/images/elite_anonymity.png',
        height: 32,
        width: 32);

    void Function() close = () {
      if (fromWelcome) {
        Navigator.of(context).popAndPushNamed(Routes.welcome);
      } else {
        Navigator.of(context).pop();
      }
    };

    Future<void> Function() saveButtonAction = () async {
      ProxySettingsStore proxy =
        ProxySettingsStore.fromSettingsStore(settingsStore);
      void Function() action = () {
        Navigator.of(context).pop();
        close();
      };
      await ProxySettingsPage.showPopupIfInvalid(context, proxy, action);
    };

    List<List<SettingsListItem>> saveButton =
      [[SaveButtonistItem(saveButtonAction)]];

    return WillPopScope(onWillPop: () async => !fromWelcome, child: Container(
        padding: EdgeInsets.only(top: 14, bottom: 14, left: 24, right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: ListView(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          if (fromWelcome)
                            Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Text(
                                S
                                    .of(context)
                                    .welcome,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  color: Theme
                                      .of(context)
                                      .primaryTextTheme
                                      .headline6!
                                      .color!,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          AspectRatio(
                            aspectRatio: aspectRatioImage,
                            child: FittedBox(
                              child: welcomeImage,
                              fit: BoxFit.contain)
                          ),
                          if (fromWelcome)
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                appDescription(context),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              S
                                  .of(context)
                                  .please_select_anonymity_level,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: PrimaryImageButton(
                                onPressed: () {
                                  settingsStore.proxyEnabled = false;
                                  settingsStore.proxyIPAddress = "";
                                  settingsStore.proxyPort = "";
                                  settingsStore.proxyAuthenticationEnabled = false;
                                  close();
                                },
                                image: standardAnonymity,
                                text: S
                                    .of(context)
                                    .standard_anonymity,
                                color: Theme.of(context).cardColor,
                                textColor: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .headline6!
                                    .color!),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: PrimaryImageButton(
                                onPressed: () {
                                  settingsStore.proxyEnabled = true;
                                  settingsStore.proxyIPAddress = "proxy.elitewallet.sc";
                                  settingsStore.proxyPort = "9999";
                                  settingsStore.proxyAuthenticationEnabled = false;
                                  close();
                                },
                                image: advancedAnonymity,
                                text: S
                                    .of(context)
                                    .advanced_anonymity,
                                color: Theme.of(context).cardColor,
                                textColor: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .headline6!
                                    .color!),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: PrimaryImageButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    Routes.proxySettings,
                                    arguments: saveButton);
                                },
                                image: eliteAnonymity,
                                text: S
                                    .of(context)
                                    .elite_anonymity,
                                color: Theme.of(context).cardColor,
                                textColor: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .headline6!
                                    .color!),
                          )
                        ],
                      )
                    ],
                  )],)
                )
              ],
            )
    ));
  }
}
