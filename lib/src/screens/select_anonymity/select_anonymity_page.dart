import 'package:elite_wallet/themes/theme_base.dart';
import 'package:flutter/material.dart';
import 'package:elite_wallet/routes.dart';
import 'package:elite_wallet/src/widgets/primary_button.dart';
import 'package:elite_wallet/src/screens/base_page.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/view_model/proxy_settings/save_button_list_item.dart';
import 'package:elite_wallet/view_model/proxy_settings/settings_list_item.dart';
import 'package:elite_wallet/wallet_type_utils.dart';

class SelectAnonymityPage extends BasePage {
  SelectAnonymityPage(this.settingsStore);

  static const aspectRatioImage = 1.25;
  final welcomeImage = Image.asset('assets/images/elitewallet_logo.png');
  SettingsStore settingsStore;

  String appDescription(BuildContext context) {
    if (isMoneroOnly) {
      return S.of(context).monero_com_wallet_text;
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
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        resizeToAvoidBottomInset: false,
        body: body(context));
  }

  @override
  Widget body(BuildContext context) {

    final standardAnonymity = Image.asset(
        'assets/images/standard_anonymity.png',
        height: 32,
        width: 32,
        color: Theme
            .of(context)
            .accentTextTheme
            .headline
            .decorationColor);
    final advancedAnonymity = Image.asset(
        'assets/images/advanced_anonymity.png',
        height: 32,
        width: 32,
        color: Theme
            .of(context)
            .accentTextTheme
            .headline
            .decorationColor);
    final eliteAnonymity = Image.asset('assets/images/elite_anonymity.png',
        height: 32,
        width: 32,
        color: Theme
            .of(context)
            .accentTextTheme
            .headline
            .decorationColor);

    void Function() showWelcomePage = () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(Routes.welcome);
    };

    List<List<SettingsListItem>> saveButton =
      [[SaveButtonistItem(showWelcomePage)]];

    return WillPopScope(onWillPop: () async => false, child: Container(
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
                                    .title
                                    .color,
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
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              appDescription(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme
                                    .of(context)
                                    .accentTextTheme
                                    .display3
                                    .color,
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
                                color: Theme
                                    .of(context)
                                    .accentTextTheme
                                    .display3
                                    .color,
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
                                  Navigator.of(context).popAndPushNamed(
                                    Routes.welcome);
                                },
                                image: standardAnonymity,
                                text: S
                                    .of(context)
                                    .standard_anonymity,
                                color: Theme
                                    .of(context)
                                    .accentTextTheme
                                    .caption
                                    .color,
                                textColor: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .title
                                    .color),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: PrimaryImageButton(
                                onPressed: () {
                                  settingsStore.proxyEnabled = true;
                                  settingsStore.proxyIPAddress = "127.0.0.1";
                                  settingsStore.proxyPort = "9150";
                                  settingsStore.proxyAuthenticationEnabled = false;
                                  Navigator.of(context).popAndPushNamed(
                                    Routes.welcome);
                                },
                                image: advancedAnonymity,
                                text: S
                                    .of(context)
                                    .advanced_anonymity,
                                color: Theme
                                    .of(context)
                                    .accentTextTheme
                                    .caption
                                    .color,
                                textColor: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .title
                                    .color),
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
                                color: Theme
                                    .of(context)
                                    .accentTextTheme
                                    .caption
                                    .color,
                                textColor: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .title
                                    .color),
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
