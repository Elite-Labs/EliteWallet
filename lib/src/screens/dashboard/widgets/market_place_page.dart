import 'package:elite_wallet/routes.dart';
import 'package:elite_wallet/src/widgets/alert_with_one_action.dart';
import 'package:elite_wallet/src/widgets/market_place_item.dart';
import 'package:elite_wallet/utils/show_pop_up.dart';
import 'package:elite_wallet/view_model/dashboard/dashboard_view_model.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:flutter/material.dart';
import 'package:elite_wallet/generated/i18n.dart';

class MarketPlacePage extends StatelessWidget {

  MarketPlacePage({required this.dashboardViewModel});

  final DashboardViewModel dashboardViewModel;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: RawScrollbar(
        thumbColor: Colors.white.withOpacity(0.15),
        radius: Radius.circular(20),
        isAlwaysShown: true,
        thickness: 2,
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Text(
                S.of(context).market_place,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentTextTheme!.headline2!.backgroundColor!,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    SizedBox(height: 20),
                    MarketPlaceItem(
                      onTap: () =>_navigatorToGiftCardsPage(context),
                      title: S.of(context).elite_pay_title,
                      subTitle: S.of(context).elite_pay_subtitle,
                    ),
                    SizedBox(height: 20),
                    MarketPlaceItem(
                      onTap: () => {},
                      title: S.of(context).elite_pay_web_cards_title,
                      subTitle: S.of(context).elite_pay_web_cards_subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _navigatorToGiftCardsPage(BuildContext context) {
    final walletType = dashboardViewModel.type;

    switch (walletType) {
      case WalletType.haven:
         showPopUp<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertWithOneAction(
                  alertTitle: S.of(context).error,
                  alertContent: S.of(context).gift_cards_unavailable,
                  buttonText: S.of(context).ok,
                  buttonAction: () => Navigator.of(context).pop());
            });
        break;
        default:
         Navigator.of(context).pushNamed(Routes.ioniaWelcomePage);
    }
  }

}
