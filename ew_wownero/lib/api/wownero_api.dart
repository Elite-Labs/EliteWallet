import 'dart:ffi';
import 'dart:io';

DynamicLibrary get wowneroApi {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return DynamicLibrary.open(
        'crypto_plugins/flutter_libmonero/scripts/linux/build/libew_wownero.so');
  }
  return Platform.isAndroid || Platform.isLinux
      ? DynamicLibrary.open("libew_wownero.so")
      : DynamicLibrary.open("ew_wownero.framework/ew_wownero");
}
