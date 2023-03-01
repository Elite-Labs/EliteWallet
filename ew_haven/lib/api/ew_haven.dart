
import 'dart:async';

import 'package:flutter/services.dart';

class EwHaven {
  static const MethodChannel _channel =
      const MethodChannel('ew_haven');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod<String>('getPlatformVersion') ?? '';
    return version;
  }
}
