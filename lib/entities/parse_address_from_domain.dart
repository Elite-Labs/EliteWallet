import 'package:elite_wallet/core/yat_service.dart';
import 'package:elite_wallet/entities/openalias_record.dart';
import 'package:elite_wallet/entities/parsed_address.dart';
import 'package:elite_wallet/entities/unstoppable_domain_address.dart';
import 'package:elite_wallet/entities/emoji_string_extension.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:flutter/foundation.dart';
import 'package:elite_wallet/entities/fio_address_provider.dart';
import 'package:elite_wallet/store/settings_store.dart';

class AddressResolver {
  
  AddressResolver(
    {@required this.yatService, this.walletType, this.settingsStore});
  
  final YatService yatService;
  final WalletType walletType;
  final SettingsStore settingsStore;
  
  static const unstoppableDomains = [
  'crypto',
  'zil',
  'x',
  'coin',
  'wallet',
  'bitcoin',
  '888',
  'nft',
  'dao',
  'blockchain'
];

  Future<ParsedAddress> resolve(String text, String ticker) async {
    try {
      if (text.contains('@') && !text.contains('.')) {
        final bool isFioRegistered = await FioAddressProvider.checkAvail(
          text, settingsStore);
        if (isFioRegistered) {
          final address = await FioAddressProvider.getPubAddress(
            text, ticker, settingsStore);
          return ParsedAddress.fetchFioAddress(address: address, name: text);
      }

      }
      if (text.hasOnlyEmojis) {
        if (walletType != WalletType.haven) {
          final addresses = await yatService.fetchYatAddress(
            text, ticker, settingsStore);
          return ParsedAddress.fetchEmojiAddress(addresses: addresses, name: text);
        }
      }
      final formattedName = OpenaliasRecord.formatDomainName(text);
      final domainParts = formattedName.split('.');
      final name = domainParts.last;

      if (domainParts.length <= 1 || domainParts.first.isEmpty || name.isEmpty) {
        return ParsedAddress(addresses: [text]);
      }

      if (unstoppableDomains.any((domain) => name.contains(domain))) {
        final address = await fetchUnstoppableDomainAddress(text, ticker);
        return ParsedAddress.fetchUnstoppableDomainAddress(address: address, name: text);
      }

      final record = await OpenaliasRecord.fetchAddressAndName(
          formattedName: formattedName, ticker: ticker);
      return ParsedAddress.fetchOpenAliasAddress(record: record, name: text);
      
    } catch (e) {
      print(e.toString());
    }

    return ParsedAddress(addresses: [text]);
  }
}
