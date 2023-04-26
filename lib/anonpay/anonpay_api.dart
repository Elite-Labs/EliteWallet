import 'dart:convert';
import 'package:elite_wallet/anonpay/anonpay_donation_link_info.dart';
import 'package:elite_wallet/anonpay/anonpay_invoice_info.dart';
import 'package:elite_wallet/anonpay/anonpay_request.dart';
import 'package:elite_wallet/anonpay/anonpay_status_response.dart';
import 'package:elite_wallet/core/fiat_conversion_service.dart';
import 'package:elite_wallet/entities/fiat_currency.dart';
import 'package:elite_wallet/exchange/limits.dart';
import 'package:elite_wallet/store/settings_store.dart';
import 'package:ew_core/crypto_currency.dart';
import 'package:ew_core/http_port_redirector.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:elite_wallet/.secrets.g.dart' as secrets;

class AnonPayApi {
  const AnonPayApi({
    this.useTorOnly = false,
    required this.wallet,
    required this.settingsStore
  });
  final bool useTorOnly;
  final WalletBase wallet;
  final SettingsStore settingsStore;

  static const anonpayRef = secrets.anonPayReferralCode;
  static const onionApiAuthority = 'trocadorfyhlu27aefre5u7zri66gudtzdyelymftvr4yjwcxhfaqsid.onion';
  static const clearNetAuthority = 'trocador.app';
  static const markup = secrets.trocadorExchangeMarkup;
  static const anonPayPath = '/anonpay';
  static const anonPayStatus = '/anonpay/status';
  static const coinPath = 'api/coin';
  static const apiKey = secrets.trocadorApiKey;

  Future<AnonpayStatusResponse> paymentStatus(String id) async {
    final authority = await _getAuthority();
    final response = await get(settingsStore, Uri.https(authority, "$anonPayStatus/$id"));
    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final status = responseJSON['Status'] as String;
    final fiatAmount = responseJSON['Fiat_Amount'] as double?;
    final fiatEquiv = responseJSON['Fiat_Equiv'] as String?;
    final amountTo = responseJSON['AmountTo'] as double?;
    final coinTo = responseJSON['CoinTo'] as String;
    final address = responseJSON['Address'] as String;

    return AnonpayStatusResponse(
      status: status,
      fiatAmount: fiatAmount,
      amountTo: amountTo,
      coinTo: coinTo,
      address: address,
      fiatEquiv: fiatEquiv,
    );
  }

  Future<AnonpayInvoiceInfo> createInvoice(AnonPayRequest request) async {
    final description = Uri.encodeComponent(request.description);
    final body = <String, dynamic>{
      'ticker_to': request.cryptoCurrency.title.toLowerCase(),
      'network_to': _networkFor(request.cryptoCurrency),
      'address': request.address,
      'name': request.name,
      'description': description,
      'email': request.email,
      'ref': anonpayRef,
      'markup': markup,
      'direct': 'False',
    };

    if (request.amount != null) {
      body['amount'] = request.amount;
    }
    if (request.fiatEquivalent != null) {
      body['fiat_equiv'] = request.fiatEquivalent;
    }
    final authority = await _getAuthority();

    final response = await get(settingsStore, Uri.https(authority, anonPayPath, body));

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final id = responseJSON['ID'] as String;
    final url = responseJSON['url'] as String;
    final urlOnion = responseJSON['url_onion'] as String;
    final statusUrl = responseJSON['status_url'] as String;
    final statusUrlOnion = responseJSON['status_url_onion'] as String;

    final statusInfo = await paymentStatus(id);

    return AnonpayInvoiceInfo(
      invoiceId: id,
      clearnetUrl: url,
      onionUrl: urlOnion,
      status: statusInfo.status,
      fiatAmount: statusInfo.fiatAmount,
      fiatEquiv: statusInfo.fiatEquiv,
      amountTo: statusInfo.amountTo,
      coinTo: statusInfo.coinTo,
      address: statusInfo.address,
      clearnetStatusUrl: statusUrl,
      onionStatusUrl: statusUrlOnion,
      walletId: wallet.id,
      createdAt: DateTime.now(),
      provider: 'Trocador AnonPay invoice',
    );
  }

  Future<AnonpayDonationLinkInfo> generateDonationLink(AnonPayRequest request) async {
    final body = <String, dynamic>{
      'ticker_to': request.cryptoCurrency.title.toLowerCase(),
      'network_to': _networkFor(request.cryptoCurrency),
      'address': request.address,
      'ref': anonpayRef,
      'direct': 'True',
    };
    if (request.name.isNotEmpty) {
      body['name'] = request.name;
    }
    if (request.description.isNotEmpty) {
      body['description'] = request.description;
    }
    if (request.email.isNotEmpty) {
      body['email'] = request.email;
    }

    final clearnetUrl = Uri.https(clearNetAuthority, anonPayPath, body);
    final onionUrl = Uri.https(onionApiAuthority, anonPayPath, body);
    return AnonpayDonationLinkInfo(
      clearnetUrl: clearnetUrl.toString(),
      onionUrl: onionUrl.toString(),
      address: request.address,
    );
  }

  Future<Limits> fetchLimits({
    FiatCurrency? fiatCurrency,
    required CryptoCurrency cryptoCurrency,
  }) async {
    double fiatRate = 0.0;
    if (fiatCurrency != null) {
      fiatRate = await FiatConversionService.fetchPrice(
        cryptoCurrency,
        fiatCurrency,
        settingsStore,
      );
    }

    final params = <String, String>{
      'api_key': apiKey,
      'ticker': cryptoCurrency.title.toLowerCase(),
      'name': cryptoCurrency.name,
    };

    final String apiAuthority = await _getAuthority();
    final uri = Uri.https(apiAuthority, coinPath, params);

    final response = await get(settingsStore, uri);

    if (response.statusCode != 200) {
      throw Exception('Unexpected http status: ${response.statusCode}');
    }

    final responseJSON = json.decode(response.body) as List<dynamic>;

    if (responseJSON.isEmpty) {
      throw Exception('No data');
    }

    final coinJson = responseJSON.first as Map<String, dynamic>;
    final minimum = coinJson['minimum'] as double;
    final maximum = coinJson['maximum'] as double;

    if (fiatCurrency != null) {
      return Limits(
        min: double.tryParse((minimum * fiatRate).toStringAsFixed(2)),
        max: double.tryParse((maximum * fiatRate).toStringAsFixed(2)),
      );
    }

    return Limits(
      min: minimum,
      max: maximum,
    );
  }

  String _networkFor(CryptoCurrency currency) {
    switch (currency) {
      case CryptoCurrency.usdt:
        return CryptoCurrency.btc.title.toLowerCase();
      default:
        return currency.tag != null ? _normalizeTag(currency.tag!) : 'Mainnet';
    }
  }

  String _normalizeTag(String tag) {
    switch (tag) {
      case 'ETH':
        return 'ERC20';
      default:
        return tag.toLowerCase();
    }
  }

  Future<String> _getAuthority() async {
    try {
      if (useTorOnly) {
        return onionApiAuthority;
      }
      final uri = Uri.https(onionApiAuthority, '/anonpay');
      await get(settingsStore, uri);
      return onionApiAuthority;
    } catch (e) {
      return clearNetAuthority;
    }
  }
}
