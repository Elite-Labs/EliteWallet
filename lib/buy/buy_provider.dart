import 'package:elite_wallet/buy/buy_amount.dart';
import 'package:elite_wallet/buy/buy_provider_description.dart';
import 'package:elite_wallet/buy/order.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/wallet_type.dart';

abstract class BuyProvider {
  BuyProvider({required this.wallet, required this.isTestEnvironment});

  final WalletBase wallet;
  final bool isTestEnvironment;

  String get title;
  BuyProviderDescription get description;
  String get trackUrl;

  WalletType get walletType => wallet.type;
  String get walletAddress => wallet.walletAddresses.address;
  String get walletId => wallet.id;

  @override
  String toString() => title;

  Future<String> requestUrl(String amount, String sourceCurrency);
  Future<Order> findOrderById(String id);
  Future<BuyAmount> calculateAmount(String amount, String sourceCurrency);
}