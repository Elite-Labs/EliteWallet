import 'package:cw_core/wallet_base.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/exchange/exchange_provider_description.dart';
import 'package:elite_wallet/view_model/dashboard/trade_list_item.dart';

part'trade_filter_store.g.dart';

class TradeFilterStore = TradeFilterStoreBase with _$TradeFilterStore;

abstract class TradeFilterStoreBase with Store {
  TradeFilterStoreBase(
      {this.displayXMRTO = true,
        this.displayMajesticBank = true,
        this.displayMorphToken = true,
        this.displaySimpleSwap = true,
        });

  @observable
  bool displayXMRTO;

  @observable
  bool displayMajesticBank;

  @observable
  bool displayMorphToken;

  @observable
  bool displaySimpleSwap;

  @action
  void toggleDisplayExchange(ExchangeProviderDescription provider) {
    switch (provider) {
      case ExchangeProviderDescription.majesticBank:
        displayMajesticBank = !displayMajesticBank;
        break;
      case ExchangeProviderDescription.xmrto:
        displayXMRTO = !displayXMRTO;
        break;
      case ExchangeProviderDescription.morphToken:
        displayMorphToken = !displayMorphToken;
        break;
      case ExchangeProviderDescription.simpleSwap:
        displaySimpleSwap = !displaySimpleSwap;
        break;
    }
  }

  List<TradeListItem> filtered({List<TradeListItem> trades, WalletBase wallet}) {
    final _trades =
    trades.where((item) => item.trade.walletId == wallet.id).toList();
    final needToFilter = !displayMajesticBank || !displayXMRTO || !displayMorphToken || !displaySimpleSwap;

    return needToFilter
        ? _trades
        .where((item) =>
    (displayXMRTO &&
        item.trade.provider == ExchangeProviderDescription.xmrto) ||
        (displayMajesticBank &&
            item.trade.provider ==
                ExchangeProviderDescription.majesticBank) ||
        (displayMorphToken &&
            item.trade.provider ==
                ExchangeProviderDescription.morphToken)
        ||(displaySimpleSwap &&
            item.trade.provider ==
                ExchangeProviderDescription.simpleSwap))
        .toList()
        : _trades;
  }
}