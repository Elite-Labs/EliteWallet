import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ew_core/elite_hive.dart';

Future<List<int>> getEncryptionKey(
    {required String forKey, required FlutterSecureStorage secureStorage}) async {
  final stringifiedKey = await secureStorage.read(key: 'transactionDescriptionsBoxKey');
  List<int> key;

  if (stringifiedKey == null) {
    key = EliteHive.generateSecureKey();
    final keyStringified = key.join(',');
    String storageKey = 'transactionDescriptionsBoxKey';
    await secureStorage.delete(key: storageKey);
    await secureStorage.write(key: storageKey, value: keyStringified);
  } else {
    key = stringifiedKey.split(',').map((i) => int.parse(i)).toList();
  }

  return key;
}
