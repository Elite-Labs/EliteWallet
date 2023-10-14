import 'package:ew_core/enumerable_item.dart';

class Elite2FAPresetsOptions extends EnumerableItem<int> with Serializable<int> {
  const Elite2FAPresetsOptions({required String super.title, required int super.raw});

  static const narrow = Elite2FAPresetsOptions(title: 'Narrow', raw: 0);
  static const normal = Elite2FAPresetsOptions(title: 'Normal', raw: 1);
  static const aggressive = Elite2FAPresetsOptions(title: 'Aggressive', raw: 2);

  static Elite2FAPresetsOptions deserialize({required int raw}) {
    switch (raw) {
      case 0:
        return Elite2FAPresetsOptions.narrow;
      case 1:
        return Elite2FAPresetsOptions.normal;
      case 2:
        return Elite2FAPresetsOptions.aggressive;
      default:
        throw Exception(
          'Incorrect Elite 2FA Preset $raw  for Elite2FAPresetOptions deserialize',
        );
    }
  }
}

enum VerboseControlSettings {
  accessWallet,
  addingContacts,
  sendsToContacts,
  sendsToNonContacts,
  sendsToInternalWallets,
  exchangesToInternalWallets,
  securityAndBackupSettings,
  creatingNewWallets,
}
