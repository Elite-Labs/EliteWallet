import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ew_monero_method_channel.dart';

abstract class EwMoneroPlatform extends PlatformInterface {
  /// Constructs a EwMoneroPlatform.
  EwMoneroPlatform() : super(token: _token);

  static final Object _token = Object();

  static EwMoneroPlatform _instance = MethodChannelEwMonero();

  /// The default instance of [EwMoneroPlatform] to use.
  ///
  /// Defaults to [MethodChannelEwMonero].
  static EwMoneroPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EwMoneroPlatform] when
  /// they register themselves.
  static set instance(EwMoneroPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
