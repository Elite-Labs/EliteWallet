import 'package:elite_wallet/themes/extensions/elite_text_theme.dart';
import 'package:elite_wallet/themes/theme_base.dart';
import 'package:elite_wallet/utils/responsive_layout_util.dart';
import 'package:flutter/material.dart';
import 'package:elite_wallet/routes.dart';
import 'package:elite_wallet/src/widgets/primary_button.dart';
import 'package:elite_wallet/src/screens/base_page.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/wallet_type_utils.dart';
import 'package:elite_wallet/themes/extensions/new_wallet_theme.dart';
import 'package:elite_wallet/themes/extensions/wallet_list_theme.dart';

class WelcomePage extends BasePage {
  static const aspectRatioImage = 1.25;
  final welcomeImageLight = Image.asset('assets/images/welcome_light.png');
  final welcomeImageDark = Image.asset('assets/images/welcome.png');

  String appTitle(BuildContext context) {
    if (isMoneroOnly) {
      return S.of(context).monero_sc;
    }

    if (isHaven) {
      return S.of(context).haven_app;
    }

    return S.of(context).elite_wallet;
  }

  String appDescription(BuildContext context) {
    if (isMoneroOnly) {
      return S.of(context).monero_sc_wallet_text;
    }

    if (isHaven) {
      return S.of(context).haven_app_wallet_text;
    }

    return S.of(context).new_first_wallet_text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        resizeToAvoidBottomInset: false,
        body: body(context));
  }

  @override
  Widget body(BuildContext context) {
    final welcomeImage = currentTheme.type == ThemeType.dark
        ? welcomeImageDark
        : welcomeImageLight;

    final newWalletImage = Image.asset('assets/images/new_wallet.png',
        height: 12,
        width: 12,
        color: Theme.of(context).extension<WalletListTheme>()!.restoreWalletButtonTextColor);
    final restoreWalletImage = Image.asset('assets/images/restore_wallet.png',
        height: 12,
       
        width: 12,
        color: Theme.of(context).extension<EliteTextTheme>()!.titleColor);

    return WillPopScope(
        onWillPop: () async => false,
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 64, bottom: 24, left: 24, right: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: ResponsiveLayoutUtilBase.kDesktopMaxWidthConstraint),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: aspectRatioImage,
                        child: FittedBox(
                            child: welcomeImage, fit: BoxFit.contain),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          S.of(context).welcome,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).extension<NewWalletTheme>()!.hintTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          appTitle(context),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).extension<EliteTextTheme>()!.titleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          appDescription(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).extension<NewWalletTheme>()!.hintTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        S.of(context).please_make_selection,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).extension<NewWalletTheme>()!.hintTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: PrimaryImageButton(
                          onPressed: () => Navigator.pushNamed(
                              context, Routes.newWalletFromWelcome),
                          image: newWalletImage,
                          text: S.of(context).create_new,
                          color: Theme.of(context).extension<WalletListTheme>()!.createNewWalletButtonBackgroundColor,
                          textColor: Theme.of(context).extension<WalletListTheme>()!.restoreWalletButtonTextColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: PrimaryImageButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, Routes.restoreOptions,
                                  arguments: true);
                            },
                            image: restoreWalletImage,
                            text: S.of(context).restore_wallet,
                            color: Theme.of(context).cardColor,
                            textColor: Theme.of(context).extension<EliteTextTheme>()!.titleColor),
                      )
                    ],
                  )
                ],
              ),
            )));
  }
}
