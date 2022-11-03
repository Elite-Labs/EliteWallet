import 'package:elite_wallet/exchange/trade.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/view_model/dashboard/action_list_item.dart';
import 'package:elite_wallet/entities/balance_display_mode.dart';

class TradeListItem extends ActionListItem {
  TradeListItem({this.trade, this.settingsStore});

  final Trade trade;
  final SettingsStore settingsStore;

  BalanceDisplayMode get displayMode => settingsStore.balanceDisplayMode;

  String get tradeFormattedAmount {
    return trade.amount != null
        ? displayMode == BalanceDisplayMode.hiddenBalance
          ? '---'
          : trade.amountFormatted()
        : trade.amount;
  }

  @override
  DateTime get date => trade.createdAt;
}
