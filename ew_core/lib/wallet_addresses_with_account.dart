import 'package:ew_core/wallet_addresses.dart';
import 'package:ew_core/account_list.dart';
import 'package:ew_core/wallet_info.dart';

abstract class WalletAddressesWithAccount<T> extends WalletAddresses {
  WalletAddressesWithAccount(WalletInfo walletInfo) : super(walletInfo);

  // T get account;

  // set account(T account);

  AccountList<T> get accountList;
}