import 'dart:async';
import 'package:ew_core/address_info.dart';
import 'package:ew_core/hive_type_ids.dart';
import 'package:ew_core/wallet_type.dart';
import 'package:hive/hive.dart';

part 'wallet_info.g.dart';

@HiveType(typeId: DERIVATION_TYPE_TYPE_ID)
enum DerivationType {
  @HiveField(0)
  unknown,
  @HiveField(1)
  def, // default is a reserved word
  @HiveField(2)
  nano,
  @HiveField(3)
  bip39,
  @HiveField(4)
  electrum1,
  @HiveField(5)
  electrum2,
}

class DerivationInfo {
  DerivationInfo({
    required this.derivationType,
    this.derivationPath,
    this.balance = "",
    this.address = "",
    this.height = 0,
    this.script_type,
    this.description,
  });

  String balance;
  String address;
  int height;
  final DerivationType derivationType;
  final String? derivationPath;
  final String? script_type;
  final String? description;
}

@HiveType(typeId: WalletInfo.typeId)
class WalletInfo extends HiveObject {
  WalletInfo(
      this.id,
      this.name,
      this.type,
      this.isRecovery,
      this.restoreHeight,
      this.timestamp,
      this.dirPath,
      this.path,
      this.address,
      this.yatEid,
      this.yatLastUsedAddressRaw,
      this.showIntroElitePayCard,
      this.derivationType,
      this.derivationPath)
      : _yatLastUsedAddressController = StreamController<String>.broadcast();

  factory WalletInfo.external({
    required String id,
    required String name,
    required WalletType type,
    required bool isRecovery,
    required int restoreHeight,
    required DateTime date,
    required String dirPath,
    required String path,
    required String address,
    bool? showIntroElitePayCard,
    String yatEid = '',
    String yatLastUsedAddressRaw = '',
    DerivationType? derivationType,
    String? derivationPath,
  }) {
    return WalletInfo(
        id,
        name,
        type,
        isRecovery,
        restoreHeight,
        date.millisecondsSinceEpoch,
        dirPath,
        path,
        address,
        yatEid,
        yatLastUsedAddressRaw,
        showIntroElitePayCard,
        derivationType,
        derivationPath);
  }

  static const typeId = WALLET_INFO_TYPE_ID;
  static const boxName = 'WalletInfo';

  @HiveField(0, defaultValue: '')
  String id;

  @HiveField(1, defaultValue: '')
  String name;

  @HiveField(2)
  WalletType type;

  @HiveField(3, defaultValue: false)
  bool isRecovery;

  @HiveField(4, defaultValue: 0)
  int restoreHeight;

  @HiveField(5, defaultValue: 0)
  int timestamp;

  @HiveField(6, defaultValue: '')
  String dirPath;

  @HiveField(7, defaultValue: '')
  String path;

  @HiveField(8, defaultValue: '')
  String address;

  @HiveField(10)
  Map<String, String>? addresses;

  @HiveField(11)
  String? yatEid;

  @HiveField(12)
  String? yatLastUsedAddressRaw;

  @HiveField(13)
  bool? showIntroElitePayCard;

  @HiveField(14)
  Map<int, List<AddressInfo>>? addressInfos;

  @HiveField(15)
  List<String>? usedAddresses;

  @HiveField(16)
  DerivationType? derivationType;

  @HiveField(17)
  String? derivationPath;

  @HiveField(18)
  String? addressPageType;

  @HiveField(19)
  String? network;

  String get yatLastUsedAddress => yatLastUsedAddressRaw ?? '';

  set yatLastUsedAddress(String address) {
    yatLastUsedAddressRaw = address;
    _yatLastUsedAddressController.add(address);
  }

  String get yatEmojiId => yatEid ?? '';

  bool get isShowIntroElitePayCard {
    if (showIntroElitePayCard == null) {
      return type != WalletType.haven;
    }
    return showIntroElitePayCard!;
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timestamp);

  Stream<String> get yatLastUsedAddressStream => _yatLastUsedAddressController.stream;

  StreamController<String> _yatLastUsedAddressController;
}
