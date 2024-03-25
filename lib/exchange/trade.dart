import 'package:elite_wallet/exchange/exchange_provider_description.dart';
import 'package:elite_wallet/exchange/trade_state.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/format_amount.dart';
import 'package:ew_core/hive_type_ids.dart';
import 'package:hive/hive.dart';

part 'trade.g.dart';

@HiveType(typeId: Trade.typeId)
class Trade extends HiveObject {
  Trade({
    required this.id,
    required this.amount,
    ExchangeProviderDescription? provider,
    CryptoCurrency? from,
    CryptoCurrency? to,
    TradeState? state,
    this.createdAt,
    this.expiredAt,
    this.inputAddress,
    this.extraId,
    this.outputTransaction,
    this.refundAddress,
    this.walletId,
    this.received,
    this.confirmed,
    this.receiveAmount,
    this.payoutAddress,
    this.password,
    this.providerId,
    this.providerName,
    this.fromWalletAddress
  }) {
    if (provider != null) providerRaw = provider.raw;

    if (from != null) fromRaw = from.raw;

    if (to != null) toRaw = to.raw;

    if (state != null) stateRaw = state.raw;
  }

  static const typeId = TRADE_TYPE_ID;
  static const boxName = 'Trades';
  static const boxKey = 'tradesBoxKey';

  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: 0)
  late int providerRaw;

  ExchangeProviderDescription get provider =>
      ExchangeProviderDescription.deserialize(raw: providerRaw);

  @HiveField(2, defaultValue: 0)
  late int fromRaw;

  CryptoCurrency get from => CryptoCurrency.deserialize(raw: fromRaw);

  @HiveField(3, defaultValue: 0)
  late int toRaw;

  CryptoCurrency get to => CryptoCurrency.deserialize(raw: toRaw);

  @HiveField(4, defaultValue: '')
  late String stateRaw;

  TradeState get state => TradeState.deserialize(raw: stateRaw);

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? expiredAt;

  @HiveField(7, defaultValue: '')
  String amount;

  @HiveField(8)
  String? inputAddress;

  @HiveField(9)
  String? extraId;

  @HiveField(10)
  String? outputTransaction;

  @HiveField(11)
  String? refundAddress;

  @HiveField(12)
  String? walletId;

  @HiveField(13)
  double? received;

  @HiveField(14)
  double? confirmed;

  @HiveField(15)
  double? receiveAmount;

  @HiveField(16)
  String? payoutAddress;

  @HiveField(17)
  String? password;

  @HiveField(18)
  String? providerId;

  @HiveField(19)
  String? providerName;

  @HiveField(20)
  String? fromWalletAddress;

  static Trade fromMap(Map<String, Object?> map) {
    return Trade(
        id: map['id'] as String,
        provider: ExchangeProviderDescription.deserialize(raw: map['provider'] as int),
        from: CryptoCurrency.deserialize(raw: map['input'] as int),
        to: CryptoCurrency.deserialize(raw: map['output'] as int),
        createdAt:
            map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int) : null,
        amount: map['amount'] as String,
        walletId: map['wallet_id'] as String,
        fromWalletAddress: map['from_wallet_address'] as String?
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'provider': provider.serialize(),
      'input': from.serialize(),
      'output': to.serialize(),
      'date': createdAt != null ? createdAt!.millisecondsSinceEpoch : null,
      'amount': amount,
      'wallet_id': walletId,
      'from_wallet_address': fromWalletAddress
    };
  }

  String amountFormatted() => formatAmount(amount);
}
