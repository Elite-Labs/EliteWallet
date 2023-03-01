import 'package:ew_core/wallet_base.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/exchange/exchange_provider_description.dart';
import 'package:elite_wallet/view_model/dashboard/trade_list_item.dart';

part'trade_filter_store.g.dart';

class TradeFilterStore = TradeFilterStoreBase with _$TradeFilterStore;

abstract class TradeFilterStoreBase with Store {
  TradeFilterStoreBase(
      {this.displayXchangeMe = true,
        this.displayMajesticBank = true,
        this.displayExch = true,
        this.displaySimpleSwap = true,
        });

  @observable
  bool displayXchangeMe;

  @observable
  bool displayMajesticBank;

  @observable
  bool displayExch;

  @observable
  bool displaySimpleSwap;

  @computed
  bool get displayAllTrades => displayXchangeMe && displayMajesticBank && displayExch && displaySimpleSwap;

  @action
  void toggleDisplayExchange(ExchangeProviderDescription provider) {
    switch (provider) {
      case ExchangeProviderDescription.majesticBank:
        displayMajesticBank = !displayMajesticBank;
        break;
      case ExchangeProviderDescription.xchangeme:
        displayXchangeMe = !displayXchangeMe;
        break;
      case ExchangeProviderDescription.exch:
        displayExch = !displayExch;
        break;
      case ExchangeProviderDescription.simpleSwap:
        displaySimpleSwap = !displaySimpleSwap;
        break;
      case ExchangeProviderDescription.all:
        if (displayAllTrades) {
          displayXchangeMe = false;
          displayMajesticBank = false;
          displayExch = false;
          displaySimpleSwap = false;
        } else {
          displayXchangeMe = true;
          displayMajesticBank = true;
          displayExch = true;
          displaySimpleSwap = true;
        }
        break;
    }
  }

  List<TradeListItem> filtered({required List<TradeListItem> trades, required WalletBase wallet}) {
    final _trades =
    trades.where((item) => item.trade.walletId == wallet.id).toList();
    final needToFilter = !displayAllTrades;

    return needToFilter
        ? _trades
        .where((item) =>
        (displayXchangeMe &&
            item.trade.provider == ExchangeProviderDescription.xchangeme) ||
        (displayMajesticBank &&
            item.trade.provider == ExchangeProviderDescription.majesticBank) ||
        (displayExch &&
            item.trade.provider == ExchangeProviderDescription.exch) ||
        (displaySimpleSwap &&
            item.trade.provider == ExchangeProviderDescription.simpleSwap))
        .toList()
        : _trades;
  }
}