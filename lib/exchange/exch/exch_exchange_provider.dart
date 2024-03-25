import 'dart:convert';
import 'package:elite_wallet/exchange/trade_not_found_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:ew_core/http_port_redirector.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/.secrets.g.dart' as secrets;
import 'package:ew_core/crypto_currency.dart';
import 'package:elite_wallet/exchange/exchange_pair.dart';
import 'package:elite_wallet/exchange/provider/exchange_provider.dart';
import 'package:elite_wallet/exchange/limits.dart';
import 'package:elite_wallet/exchange/trade.dart';
import 'package:elite_wallet/exchange/trade_request.dart';
import 'package:elite_wallet/exchange/trade_state.dart';
import 'package:elite_wallet/exchange/exch/exch_request.dart';
import 'package:elite_wallet/exchange/exchange_provider_description.dart';
import 'package:elite_wallet/exchange/trade_not_created_exception.dart';

class ExchExchangeProvider extends ExchangeProvider {
  ExchExchangeProvider(this.settingsStore)
      : super(pairList: _supportedPairs());

  static const List<CryptoCurrency> _supported = [
    CryptoCurrency.btc,
    CryptoCurrency.ltc,
    CryptoCurrency.xmr,
    CryptoCurrency.dash,
    CryptoCurrency.eth,
    CryptoCurrency.usdt,
    CryptoCurrency.usdc,
    CryptoCurrency.dai,
  ];

  static List<ExchangePair> _supportedPairs() {
    final supportedCurrencies = CryptoCurrency.all
        .where((element) => _supported.contains(element))
        .toList();

    return supportedCurrencies
        .map((i) => supportedCurrencies
            .map((k) => ExchangePair(from: i, to: k, reverse: true)))
        .expand((i) => i)
        .toList();
  }

  static const referrerId = 'BB699cDb';
  static const apiAuthorityDirect = 'exch.cx';
  static const apiAuthorityOnion =
    'hszyoqwrcp7cxlxnqmovp6vjvmnwj33g4wviuxqzq47emieaxjaperyd.onion';
  static const createTradePath = '/api/create';
  static const findTradeByIdPath = '/api/order';
  static const fetchRatePath = '/api/rates';

  @override
  String get title => 'Exch ';

  @override
  bool get isAvailable => true;

  @override
  bool get isEnabled => true;

  @override
  bool get supportsFixedRate => true;

  @override
  ExchangeProviderDescription get description =>
      ExchangeProviderDescription.exch;

  @override
  Future<bool> checkIsAvailable() async => true;

  SettingsStore settingsStore;

  int fetchRateSequenceId = 0;

  @override
  Future<Limits> fetchLimits({
    required CryptoCurrency from, required CryptoCurrency to,
    required bool isFixedRateMode}) async {

    throw Exception("Not implemented");
  }

  @override
  Future<Trade> createTrade({
    required TradeRequest request, required bool isFixedRateMode}) async {

    try {
      return await _createTradeInternal(
        request: request, isFixedRateMode: isFixedRateMode,
        apiAuthority: apiAuthorityOnion);
    } catch (_) {}
    return _createTradeInternal(
      request: request, isFixedRateMode: isFixedRateMode,
      apiAuthority: apiAuthorityDirect);
  }

  Future<Trade> _createTradeInternal({
    required TradeRequest request, required bool isFixedRateMode,
    required String apiAuthority}) async {

    final _request = request as ExchRequest;
    final body = <String, String>{
      'from_currency': normalizeCryptoCurrency(_request.from), 
      'to_currency': normalizeCryptoCurrency(_request.to),
      'to_address': _request.address,
      'refund_address': _request.refundAddress,
      'rate_mode': isFixedRateMode ? "flat" : "dynamic",
      'ref': referrerId,
    };

    Uri uri = Uri.https(apiAuthority, createTradePath);
    final response = await post(settingsStore, uri, body: json.encode(body));

    if (response.statusCode == 400) {
      final responseJSON = json.decode(response.body) as Map<String, dynamic>;
      final error = responseJSON['error'] as String;
      final message = responseJSON['message'] as String;
      throw Exception('${error}\n$message');
    }

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final id = responseJSON['orderid'] as String;

    return findTradeById(id: id);
  }

  @override
  Future<Trade> findTradeById({
    required String id}) async {
    try {
      return await _findTradeByIdInternal(
        id: id, apiAuthority: apiAuthorityOnion);
    } catch (_) {}
    return _findTradeByIdInternal(id: id, apiAuthority: apiAuthorityDirect);
  }

  Future<Trade> _findTradeByIdInternal({
    required String id,
    required String apiAuthority,
    String fromAmount = ""}) async {

    final body = <String, String>{'orderid': id};
    final uri = Uri.https(apiAuthority, findTradeByIdPath);
    final response = await post(settingsStore, uri, body: json.encode(body));

    if (response.statusCode == 404) {
      throw TradeNotFoundException(id, provider: description);
    }

    if (response.statusCode == 400) {
      final responseJSON = json.decode(response.body) as Map<String, dynamic>;
      final error = responseJSON['message'] as String;

      throw TradeNotFoundException(id,
          provider: description, description: error);
    }

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;

    if (!responseJSON.containsKey('from_currency')) {
      throw Exception('from_currency invalid!');
    }

    final fromCurrency = responseJSON['from_currency'] as String;
    CryptoCurrency from = CryptoCurrency.fromString(fromCurrency);

    if (!responseJSON.containsKey('to_currency')) {
      throw Exception('to_currency invalid!');
    }

    final toCurrency = responseJSON['to_currency'] as String;
    CryptoCurrency to = CryptoCurrency.fromString(toCurrency);

    final inputAddress = responseJSON['from_addr'] as String;

    double received = 0;
    if (responseJSON.containsKey('from_amount_received')) {
      received = _toDouble(responseJSON['from_amount_received']);
    }

    double receiveAmount = 0;
    if (responseJSON.containsKey('to_amount')) {
      receiveAmount = _toDouble(responseJSON['to_amount']);
    }

    final stateStr = responseJSON['state'] as String;
    final state = TradeState.deserialize(raw: _parseStatus(stateStr));

    return Trade(
        id: id,
        from: from,
        to: to,
        provider: description,
        inputAddress: inputAddress,
        amount: fromAmount,
        receiveAmount: receiveAmount,
        received: received,
        state: state);
  }

  @override
  Future<double> fetchRate(
      {required CryptoCurrency from,
      required CryptoCurrency to,
      required double amount,
      required bool isFixedRateMode,
      required bool isReceiveAmount}) async {

    int currentfetchRateSequenceId = ++fetchRateSequenceId;

    try {
      double t = await _fetchRateInternal(
        from: from, to: to, amount: amount, isFixedRateMode: isFixedRateMode,
        isReceiveAmount: isReceiveAmount, apiAuthority: apiAuthorityOnion);
      if (currentfetchRateSequenceId != fetchRateSequenceId) {
        throw "Stale fetchRate request!";
      }
      return t;
    } catch (_) {}
    try {
      double t = await _fetchRateInternal(
        from: from, to: to, amount: amount, isFixedRateMode: isFixedRateMode,
        isReceiveAmount: isReceiveAmount, apiAuthority: apiAuthorityDirect);
      if (currentfetchRateSequenceId != fetchRateSequenceId) {
        throw "Stale fetchRate request!";
      }
      return t;
    } catch (_) {}
    return 0.0;
  }

  Future<double> _fetchRateInternal(
      {required CryptoCurrency from,
      required CryptoCurrency to,
      required double amount,
      required bool isFixedRateMode,
      required bool isReceiveAmount,
      required String apiAuthority}) async {

    if (amount == 0) {
      return 0.0;
    }

    final isReverse = isReceiveAmount;
    final body = <String, String>{
      'rate_mode': isFixedRateMode ? "flat" : "dynamic",
    };

    final uri = Uri.https(apiAuthority, fetchRatePath);
    final response = await post(settingsStore, uri, body: json.encode(body));
    final responseJSON = json.decode(response.body) as Map<String, dynamic>;

    final pairKey =
      normalizeCryptoCurrency(from) + "_" + normalizeCryptoCurrency(to);

    if (!responseJSON.containsKey(pairKey)) {
      return 0.0;
    }

    final rate = _toDouble(responseJSON[pairKey]["rate"]);
    if (rate == 0) {
      return 0.0;
    }

    return rate;
  }

  static String _parseStatus(String input) {
    if (input == "CREATED") {
      return "created";
    }
    if (input == "CANCELLED") {
      return "failed";
    }
    if (input == "AWAITING_INPUT") {
      return "pending";
    }
    if (input == "CONFIRMING_INPUT") {
      return "confirming";
    }
    if (input == "EXCHANGING") {
      return "trading";
    }
    if (input == "CONFIRMING_SEND") {
      return "trading";
    }
    if (input == "COMPLETE") {
      return "completed";
    }
    if (input == "REFUND_REQUEST") {
      return "failed";
    }
    if (input == "REFUND_PENDING") {
      return "failed";
    }
    if (input == "CONFIRMING_REFUND") {
      return "failed";
    }
    if (input == "REFUNDED") {
      return "completed";
    }
    return input;
  }

  static double _toDouble(dynamic input) {
    return double.parse(input.toString());
  }

  static String normalizeCryptoCurrency(CryptoCurrency currency) {
    return currency.title.toUpperCase();
  }
}
