import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ew_monero_platform_interface.dart';

/// An implementation of [EwMoneroPlatform] that uses method channels.
class MethodChannelEwMonero extends EwMoneroPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ew_monero');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
