import 'package:elite_wallet/entities/balance_display_mode.dart';
import 'package:elite_wallet/exchange/trade.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/view_model/dashboard/action_list_item.dart';

class TradeListItem extends ActionListItem {
  TradeListItem({required this.trade, required this.settingsStore});

  final Trade trade;
  final SettingsStore settingsStore;

  BalanceDisplayMode get displayMode => settingsStore.balanceDisplayMode;

  String get tradeFormattedAmount =>
      displayMode == BalanceDisplayMode.hiddenBalance ? '---' : trade.amountFormatted();

  @override
  DateTime get date => trade.createdAt!;
}
