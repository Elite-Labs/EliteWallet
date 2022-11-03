import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/core/validator.dart';

class WalletNameValidator extends TextValidator {
  WalletNameValidator()
      : super(
            errorMessage: S.current.error_text_wallet_name,
            pattern: '^[a-zA-Z0-9\-_ ]+\$',
            minLength: 1,
            maxLength: 33);
}
