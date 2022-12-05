import 'package:elite_wallet/view_model/send/output.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/entities/template.dart';
import 'package:elite_wallet/store/templates/send_template_store.dart';
import 'package:elite_wallet/core/template_validator.dart';
import 'package:elite_wallet/core/address_validator.dart';
import 'package:elite_wallet/core/amount_validator.dart';
import 'package:elite_wallet/core/validator.dart';
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/crypto_currency.dart';
import 'package:elite_wallet/entities/fiat_currency.dart';
import 'package:elite_wallet/store/dashboard/fiat_conversion_store.dart';
import 'package:elite_wallet/store/settings_store.dart';

part 'send_template_view_model.g.dart';

class SendTemplateViewModel = SendTemplateViewModelBase
    with _$SendTemplateViewModel;

abstract class SendTemplateViewModelBase with Store {
  SendTemplateViewModelBase(this._wallet, this._settingsStore,
      this._sendTemplateStore, this._fiatConversationStore) {

    output = Output(_wallet, _settingsStore, _fiatConversationStore, () => currency);
  }

  Output output;

  Validator get amountValidator => AmountValidator(type: _wallet.type);

  Validator get addressValidator => AddressValidator(type: _wallet.currency);

  Validator get templateValidator => TemplateValidator();

  CryptoCurrency get currency => _wallet.currency;

  FiatCurrency get fiat => _settingsStore.fiatCurrency;

  @observable
  bool isCurrencySelected = true;

  @observable
  bool isFiatSelected = false;

  @action
  void selectCurrency () {
    isCurrencySelected = true;
    isFiatSelected = false;
  }

  @action
  void selectFiat () {
    isFiatSelected = true;
    isCurrencySelected = false;
  }

  @computed
  ObservableList<Template> get templates => _sendTemplateStore.templates;

  final WalletBase _wallet;
  final SettingsStore _settingsStore;
  final SendTemplateStore _sendTemplateStore;
  final FiatConversionStore _fiatConversationStore;

  void updateTemplate() => _sendTemplateStore.update();

  void addTemplate(
      {String name,
        bool isCurrencySelected,
        String address,
        String cryptoCurrency,
        String fiatCurrency,
        String amount,
        String amountFiat}) {
    _sendTemplateStore.addTemplate(
        name: name,
        isCurrencySelected: isCurrencySelected,
        address: address,
        cryptoCurrency: cryptoCurrency,
        fiatCurrency: fiatCurrency,
        amount: amount,
        amountFiat: amountFiat);
    updateTemplate();
  }

  void removeTemplate({Template template}) {
    _sendTemplateStore.remove(template: template);
    updateTemplate();
  }
}
