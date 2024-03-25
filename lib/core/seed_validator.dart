import 'package:elite_wallet/bitcoin/bitcoin.dart';
import 'package:elite_wallet/ethereum/ethereum.dart';
import 'package:elite_wallet/haven/haven.dart';
import 'package:elite_wallet/wownero/wownero.dart';
import 'package:elite_wallet/core/validator.dart';
import 'package:elite_wallet/entities/mnemonic_item.dart';
import 'package:elite_wallet/polygon/polygon.dart';
import 'package:elite_wallet/solana/solana.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:elite_wallet/monero/monero.dart';
import 'package:elite_wallet/nano/nano.dart';
import 'package:elite_wallet/utils/language_list.dart';

class SeedValidator extends Validator<MnemonicItem> {
  SeedValidator({required this.type, required this.language})
      : _words = getWordList(type: type, language: language),
        super(errorMessage: 'Wrong seed mnemonic');

  final WalletType type;
  final String language;
  final List<String> _words;

  static List<String> getWordList({required WalletType type, required String language}) {
    switch (type) {
      case WalletType.bitcoin:
        return getBitcoinWordList(language);
      case WalletType.litecoin:
        return getBitcoinWordList(language);
      case WalletType.monero:
        return monero!.getMoneroWordList(language);
      case WalletType.wownero:
        return wownero!.getWowneroWordList(language);
      case WalletType.haven:
        return haven!.getMoneroWordList(language);
      case WalletType.ethereum:
        return ethereum!.getEthereumWordList(language);
      case WalletType.bitcoinCash:
        return getBitcoinWordList(language);
      case WalletType.nano:
      case WalletType.banano:
        return nano!.getNanoWordList(language);
      case WalletType.polygon:
        return polygon!.getPolygonWordList(language);
      case WalletType.solana:
        return solana!.getSolanaWordList(language);
      default:
        return <String>[];
    }
  }

  static List<String> getBitcoinWordList(String language) {
    assert(language.toLowerCase() == LanguageList.english.toLowerCase());
    return bitcoin!.getWordList();
  }

  @override
  bool isValid(MnemonicItem? value) => _words.contains(value?.text);
}
