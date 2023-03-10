import 'package:elite_wallet/entities/balance_display_mode.dart';
import 'package:elite_wallet/entities/fiat_currency.dart';
import 'package:ew_core/transaction_info.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/view_model/dashboard/action_list_item.dart';
import 'package:elite_wallet/monero/monero.dart';
import 'package:elite_wallet/haven/haven.dart';
import 'package:elite_wallet/wownero/wownero.dart';
import 'package:elite_wallet/bitcoin/bitcoin.dart';
import 'package:elite_wallet/entities/calculate_fiat_amount_raw.dart';
import 'package:elite_wallet/view_model/dashboard/balance_view_model.dart';
import 'package:ew_core/keyable.dart';
import 'package:ew_core/wallet_type.dart';

class TransactionListItem extends ActionListItem with Keyable {
  TransactionListItem(
      {required this.transaction,
      required this.balanceViewModel,
      required this.settingsStore});

  final TransactionInfo transaction;
  final BalanceViewModel balanceViewModel;
  final SettingsStore settingsStore;

  double get price => balanceViewModel.price;

  FiatCurrency get fiatCurrency => settingsStore.fiatCurrency;

  BalanceDisplayMode get displayMode => settingsStore.balanceDisplayMode;

  @override
  dynamic get keyIndex => transaction.id;

  String get formattedCryptoAmount {
    return displayMode == BalanceDisplayMode.hiddenBalance
        ? '---'
        : transaction.amountFormatted();
  }

  String get formattedFiatAmount {
    var amount = '';

    switch(balanceViewModel.wallet.type) {
      case WalletType.monero:
        amount = calculateFiatAmountRaw(
          cryptoAmount: monero!.formatterMoneroAmountToDouble(amount: transaction.amount),
          price: price);
        break;
      case WalletType.bitcoin:
      case WalletType.litecoin:
        amount = calculateFiatAmountRaw(
          cryptoAmount: bitcoin!.formatterBitcoinAmountToDouble(amount: transaction.amount),
          price: price);
        break;
      case WalletType.haven:
        final asset = haven!.assetOfTransaction(transaction);
        final price = balanceViewModel.fiatConvertationStore.prices[asset];
        amount = calculateFiatAmountRaw(
          cryptoAmount: haven!.formatterMoneroAmountToDouble(amount: transaction.amount),
          price: price);
        break;
      case WalletType.wownero:
        amount = calculateFiatAmountRaw(
            cryptoAmount: wownero!.formatterWowneroAmountToDouble(amount: transaction.amount),
            price: price);
        break;
      default:
        break;
    }

    transaction.changeFiatAmount(amount);
    return displayMode == BalanceDisplayMode.hiddenBalance
        ? '---'
        : fiatCurrency.title + ' ' + transaction.fiatAmount();
  }

  @override
  DateTime get date => transaction.date;
}
