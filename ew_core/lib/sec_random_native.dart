import 'dart:typed_data';

import 'package:flutter/services.dart';

const utils = const MethodChannel('sc.elite_wallet/native_utils');

Future<Uint8List> secRandom(int count) async {
  try {
    return await utils.invokeMethod<Uint8List>('sec_random', {'count': count}) ?? Uint8List.fromList(<int>[]);
  } on PlatformException catch (_) {
    return Uint8List.fromList(<int>[]);
  }
}
