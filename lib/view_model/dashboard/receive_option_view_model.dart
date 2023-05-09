import 'package:elite_wallet/entities/receive_page_option.dart';
import 'package:ew_core/wallet_base.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:mobx/mobx.dart';

part 'receive_option_view_model.g.dart';

class ReceiveOptionViewModel = ReceiveOptionViewModelBase with _$ReceiveOptionViewModel;

abstract class ReceiveOptionViewModelBase with Store {
  ReceiveOptionViewModelBase(this._wallet, this.initialPageOption)
      : selectedReceiveOption = initialPageOption ?? ReceivePageOption.mainnet,
        _options = [ReceivePageOption.mainnet] {
    final walletType = _wallet.type;
  }

  final WalletBase _wallet;

  final ReceivePageOption? initialPageOption;

  List<ReceivePageOption> _options;

  @observable
  ReceivePageOption selectedReceiveOption;

  List<ReceivePageOption> get options => _options;

  @action
  void selectReceiveOption(ReceivePageOption option) {
    selectedReceiveOption = option;
  }
}
