import 'package:ew_core/wallet_type.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:elite_wallet/src/screens/transaction_details/standart_list_item.dart';
import 'package:elite_wallet/monero/monero.dart';
import 'package:elite_wallet/haven/haven.dart';
import 'package:elite_wallet/wownero/wownero.dart';

part 'wallet_keys_view_model.g.dart';

class WalletKeysViewModel = WalletKeysViewModelBase with _$WalletKeysViewModel;

abstract class WalletKeysViewModelBase with Store {
  WalletKeysViewModelBase(WalletBase wallet)
      : title = wallet.type == WalletType.bitcoin || wallet.type == WalletType.litecoin
            ? S.current.wallet_seed
            : S.current.wallet_keys,
        items = ObservableList<StandartListItem>() {
    if (wallet.type == WalletType.monero) {
      final keys = monero!.getKeys(wallet);

      items.addAll([
        if (keys['publicSpendKey'] != null)
          StandartListItem(title: S.current.spend_key_public, value: keys['publicSpendKey']!),
        if (keys['privateSpendKey'] != null)
          StandartListItem(title: S.current.spend_key_private, value: keys['privateSpendKey']!),
        if (keys['publicViewKey'] != null)
          StandartListItem(title: S.current.view_key_public, value: keys['publicViewKey']!),
        if (keys['privateViewKey'] != null)
          StandartListItem(title: S.current.view_key_private, value: keys['privateViewKey']!),
        StandartListItem(title: S.current.wallet_seed, value: wallet.seed),
      ]);
    }

    if (wallet.type == WalletType.haven) {
      final keys = haven!.getKeys(wallet);

      items.addAll([
        if (keys['publicSpendKey'] != null)
          StandartListItem(title: S.current.spend_key_public, value: keys['publicSpendKey']!),
        if (keys['privateSpendKey'] != null)
          StandartListItem(title: S.current.spend_key_private, value: keys['privateSpendKey']!),
        if (keys['publicViewKey'] != null)
          StandartListItem(title: S.current.view_key_public, value: keys['publicViewKey']!),
        if (keys['privateViewKey'] != null)
          StandartListItem(title: S.current.view_key_private, value: keys['privateViewKey']!),
        StandartListItem(title: S.current.wallet_seed, value: wallet.seed),
      ]);
    }

    if (wallet.type == WalletType.wownero) {
      final keys = wownero!.getKeys(wallet);

      items.addAll([
        if (keys['publicSpendKey'] != null)
          StandartListItem(title: S.current.spend_key_public, value: keys['publicSpendKey']!),
        if (keys['privateSpendKey'] != null)
          StandartListItem(title: S.current.spend_key_private, value: keys['privateSpendKey']!),
        if (keys['publicViewKey'] != null)
          StandartListItem(title: S.current.view_key_public, value: keys['publicViewKey']!),
        if (keys['privateViewKey'] != null)
          StandartListItem(title: S.current.view_key_private, value: keys['privateViewKey']!),
        StandartListItem(title: S.current.wallet_seed, value: wallet.seed),
      ]);
    }

    if (wallet.type == WalletType.bitcoin || wallet.type == WalletType.litecoin) {
      items.addAll([
        StandartListItem(title: S.current.wallet_seed, value: wallet.seed),
      ]);
    }
  }

  final ObservableList<StandartListItem> items;

  final String title;
}
