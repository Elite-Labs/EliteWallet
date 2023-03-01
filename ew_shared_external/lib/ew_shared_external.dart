
import 'dart:async';

import 'package:flutter/services.dart';

class EwSharedExternal {
  static const MethodChannel _channel =
      const MethodChannel('ew_shared_external');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
