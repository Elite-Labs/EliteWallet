
import 'ew_monero_platform_interface.dart';

class EwMonero {
  Future<String?> getPlatformVersion() {
    return EwMoneroPlatform.instance.getPlatformVersion();
  }
}
