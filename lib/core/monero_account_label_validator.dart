import 'package:flutter/foundation.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/core/validator.dart';
import 'package:cw_core/crypto_currency.dart';

class MoneroLabelValidator extends TextValidator {
  MoneroLabelValidator({@required CryptoCurrency type})
      : super(
      errorMessage: S.current.error_text_account_name,
      pattern: '^[a-zA-Z0-9_ ]{1,15}\$',
      minLength: 1,
      maxLength: 15);
}
