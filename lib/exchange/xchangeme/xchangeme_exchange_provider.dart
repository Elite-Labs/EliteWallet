import 'dart:convert';
import 'package:elite_wallet/exchange/trade_not_found_exeption.dart';
import 'package:flutter/foundation.dart';
import 'package:ew_core/http_port_redirector.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:elite_wallet/.secrets.g.dart' as secrets;
import 'package:ew_core/crypto_currency.dart';
import 'package:elite_wallet/exchange/exchange_pair.dart';
import 'package:elite_wallet/exchange/exchange_provider.dart';
import 'package:elite_wallet/exchange/limits.dart';
import 'package:elite_wallet/exchange/trade.dart';
import 'package:elite_wallet/exchange/trade_request.dart';
import 'package:elite_wallet/exchange/trade_state.dart';
import 'package:elite_wallet/exchange/xchangeme/xchangeme_request.dart';
import 'package:elite_wallet/exchange/exchange_provider_description.dart';
import 'package:elite_wallet/exchange/trade_not_created_exeption.dart';
import 'package:elite_wallet/entities/exchange_api_mode.dart';

class XchangeMeExchangeProvider extends ExchangeProvider {
  XchangeMeExchangeProvider(this.settingsStore)
      : super(pairList: _supportedPairs());
  static const List<CryptoCurrency> _supported = [
    CryptoCurrency.btc,
    CryptoCurrency.dash,
    CryptoCurrency.eth,
    CryptoCurrency.firo,
    CryptoCurrency.kmd,
    CryptoCurrency.ltc,
    CryptoCurrency.xmr,
    CryptoCurrency.zec,
    CryptoCurrency.ada,
    CryptoCurrency.bch,
    CryptoCurrency.bnb,
    CryptoCurrency.dai,
    CryptoCurrency.eos,
    CryptoCurrency.trx,
    CryptoCurrency.usdt,
    CryptoCurrency.usdterc20,
    CryptoCurrency.xlm,
    CryptoCurrency.xrp,
    CryptoCurrency.xhv,
    CryptoCurrency.btt,
    CryptoCurrency.doge,
    CryptoCurrency.usdttrc20,
    CryptoCurrency.hbar,
    CryptoCurrency.sc,
    CryptoCurrency.sol,
    CryptoCurrency.usdc,
    CryptoCurrency.zen,
    CryptoCurrency.xvg,
    CryptoCurrency.dcr,
    CryptoCurrency.mana,
    CryptoCurrency.maticpoly,
    CryptoCurrency.mkr,
    CryptoCurrency.oxt,
    CryptoCurrency.pivx,
    CryptoCurrency.rvn,
    CryptoCurrency.stx,
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

  static const inviteCode = 'elitewallet';
  static const apiAuthorityDirect = 'xchange.me';
  static const apiAuthorityOnion =
    'xmxmrjoqo63c5notr2ds2t3pdpsg4ysqqe6e6uu2pycecmjs4ekzpmyd.onion';
  static const createTradePath = '/api/v1/exchange';
  static const limitsPath = '/api/v1/exchange';
  static const findTradeByIdPath = '/api/v1/exchange/';
  static const fetchRatePath = '/api/v1/exchange/estimate';

  @override
  String get title => 'Xchange.me';

  @override
  bool get isAvailable => true;

  @override
  bool get isEnabled => true;

  @override
  bool get supportsFixedRate => false;

  @override
  bool get supportsOnionAddress => true;

  @override
  ExchangeProviderDescription get description =>
      ExchangeProviderDescription.xchangeme;

  @override
  Future<bool> checkIsAvailable() async => true;

  SettingsStore settingsStore;

  @override
  Future<Limits> fetchLimits({
    required CryptoCurrency from, required CryptoCurrency to,
    required bool isFixedRateMode}) async {

    throw Exception("Not implemented");
  }

  @override
  Future<Trade> createTrade({
    required TradeRequest request, required bool isFixedRateMode}) async {

    Object? exception;
    for (final apiAuthority in getApiAuthorities()) {
      try {
        return await _createTradeInternal(
          request: request, isFixedRateMode: isFixedRateMode,
          apiAuthority: apiAuthority);
      } catch (e) {
        exception = e;
      }
    }
    throw exception!;
  }

  Future<Trade> _createTradeInternal({
    required TradeRequest request, required bool isFixedRateMode,
    required String apiAuthority}) async {

    final _request = request as XchangeMeRequest;
    final body = <String, dynamic>{
      'from_currency': normalizeCryptoCurrency(_request.from), 
      'from_currency_alt': false,
      'to_currency': normalizeCryptoCurrency(_request.to),
      'receive_address': _request.address,
      'refund_address': _request.refundAddress,
      'from_amount': _request.fromAmount,
      'invite_code': inviteCode
    };

    if (_request.to.tag != null) {
      body['withdraw_to'] = _request.to.tag?.toLowerCase();
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent': 'xchangeme-cli',
    };

    Uri uri = Uri.https(apiAuthority, createTradePath);

    final response = await post(settingsStore, uri,
                                headers: headers, body: json.encode(body));

    if (response.statusCode == 422) {
      final responseJSON = json.decode(response.body) as Map<String, dynamic>;
      final message = responseJSON['message'] as String;
      throw Exception('$message');
    }

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final id = responseJSON['uuid'] as String;
    final inputAddress = responseJSON['send_address'] as String;
    final payoutAddress = responseJSON['receive_address'] as String;
    final refundAddress = responseJSON['refund_address'] as String;
    final fromAmount = responseJSON['from_amount'].toString();
    final minAmount = responseJSON['minimum_payment'].toString();
    if (_toDouble(fromAmount) < _toDouble(minAmount)) {
      throw Exception('From amount is smaller than minimum amount.');
    }
    final expiration = _toInt(responseJSON['time_left_for_payment']);
    DateTime now = DateTime.now();
    DateTime expiredAt = now.add(Duration(seconds: expiration));

    return Trade(
        id: id,
        from: _request.from,
        to: _request.to,
        provider: description,
        inputAddress: inputAddress,
        payoutAddress: payoutAddress,
        refundAddress: refundAddress,
        createdAt: now,
        expiredAt: expiredAt,
        amount: fromAmount,
        state: TradeState.created);
  }

  @override
  Future<Trade> findTradeById({
    required String id}) async {
    Object? exception;
    for (final apiAuthority in getApiAuthorities()) {
      try {
        return await _findTradeByIdInternal(
          id: id, apiAuthority: apiAuthority);
      } catch (e) {
        exception = e;
      }
    }
    throw exception!;
  }

  Future<Trade> _findTradeByIdInternal({
    required String id,
    required String apiAuthority}) async {

    final uri = Uri.https(apiAuthority, findTradeByIdPath + id);
    final response = await get(settingsStore, uri);

    if (response.statusCode == 422) {
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
    fromCurrency.toUpperCase();
    CryptoCurrency from = CryptoCurrency.fromString(fromCurrency);

    if (!responseJSON.containsKey('to_currency')) {
      throw Exception('to_currency invalid!');
    }

    final toCurrency = responseJSON['to_currency'] as String;
    toCurrency.toUpperCase();
    CryptoCurrency to = CryptoCurrency.fromString(toCurrency);

    final inputAddress = responseJSON['send_address'] as String;
    final payoutAddress = responseJSON['receive_address'] as String;
    final refundAddress = responseJSON['refund_address'] as String;

    String expectedSendAmount = "";
    if (responseJSON.containsKey('from_amount')) {
      expectedSendAmount = responseJSON['from_amount'].toString();
    }

    double receiveAmount = 0;
    if (responseJSON.containsKey('receive_amount')) {
      receiveAmount = _toDouble(responseJSON['receive_amount']);
    }

    final status = _parseStatus(responseJSON['stage'] as String);
    final state = TradeState.deserialize(raw: status);

    return Trade(
        id: id,
        from: from,
        to: to,
        provider: description,
        inputAddress: inputAddress,
        payoutAddress: payoutAddress,
        refundAddress: refundAddress,
        amount: expectedSendAmount,
        receiveAmount: receiveAmount,
        state: state);
  }

  @override
  Future<double> fetchRate(
      {required CryptoCurrency from,
      required CryptoCurrency to,
      required double amount,
      required bool isFixedRateMode,
      required bool isReceiveAmount}) async {

    for (final apiAuthority in getApiAuthorities()) {
      try {
        double t = await _fetchRateInternal(
          from: from, to: to, amount: amount, isFixedRateMode: isFixedRateMode,
          isReceiveAmount: isReceiveAmount, apiAuthority: apiAuthority);
        return t;
      } catch (_) {}
    }
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
    final params = <String, String>{
      'Accept': 'application/json',
      'User-Agent': 'xchangeme-cli',
      'from_currency':normalizeCryptoCurrency(from),
      'to_currency': normalizeCryptoCurrency(to),
      'amount': amount.toString(),
      };


    final uri = Uri.https(apiAuthority, fetchRatePath, params);
    final response = await get(settingsStore, uri);
    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final toAmount = _toDouble(responseJSON['estimate']);

    return toAmount / amount;
  }

  List<String> getApiAuthorities() {
    if (settingsStore.exchangeStatus == ExchangeApiMode.torOnly) {
      return [apiAuthorityOnion];
    }
    return [apiAuthorityOnion, apiAuthorityDirect];
  }

  static String _parseStatus(String input) {
    if (input == "UNPAID" || input == "DONE") {
      return input;
    }
    return 'pending';
  }

  static double _toDouble(dynamic input) {
    return double.parse(input.toString());
  }

  static int _toInt(dynamic input) {
    return int.parse(input.toString());
  }

  static String normalizeCryptoCurrency(CryptoCurrency currency) {
    return currency.title.toLowerCase();
  }
}
