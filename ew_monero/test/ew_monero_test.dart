import 'package:flutter_test/flutter_test.dart';
import 'package:ew_monero/ew_monero.dart';
import 'package:ew_monero/ew_monero_platform_interface.dart';
import 'package:ew_monero/ew_monero_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEwMoneroPlatform
    with MockPlatformInterfaceMixin
    implements EwMoneroPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EwMoneroPlatform initialPlatform = EwMoneroPlatform.instance;

  test('$MethodChannelEwMonero is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEwMonero>());
  });

  test('getPlatformVersion', () async {
    EwMonero ewMoneroPlugin = EwMonero();
    MockEwMoneroPlatform fakePlatform = MockEwMoneroPlatform();
    EwMoneroPlatform.instance = fakePlatform;

    expect(await ewMoneroPlugin.getPlatformVersion(), '42');
  });
}
