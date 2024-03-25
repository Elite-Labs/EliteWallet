import 'package:ew_core/elite_hive.dart';
import 'package:ew_core/wallet_addresses.dart';
import 'package:ew_core/wallet_info.dart';
import 'package:ew_core/nano_account.dart';
import 'package:ew_nano/nano_account_list.dart';
import 'package:mobx/mobx.dart';

part 'nano_wallet_addresses.g.dart';

class NanoWalletAddresses = NanoWalletAddressesBase with _$NanoWalletAddresses;

abstract class NanoWalletAddressesBase extends WalletAddresses with Store {
  NanoWalletAddressesBase(WalletInfo walletInfo)
      : accountList = NanoAccountList(walletInfo.address),
        address = '',
        super(walletInfo);
  @override
  @observable
  String address;

  @observable
  NanoAccount? account;

  NanoAccountList accountList;

  @override
  Future<void> init() async {
    var box = await EliteHive.openBox<NanoAccount>(walletInfo.address);
    try {
      box.getAt(0);
    } catch (e) {
      box.add(NanoAccount(id: 0, label: "Primary Account", balance: "0.00"));
    }

    await accountList.update(walletInfo.address);
    account = accountList.accounts.first;
    address = walletInfo.address;
  }

  @override
  Future<void> updateAddressesInBox() async {
    try {
      addressesMap.clear();
      addressesMap[address] = '';
      await saveAddressesInBox();
    } catch (e) {
      print(e.toString());
    }
  }
}
