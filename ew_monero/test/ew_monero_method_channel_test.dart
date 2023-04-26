import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ew_monero/ew_monero_method_channel.dart';

void main() {
  MethodChannelEwMonero platform = MethodChannelEwMonero();
  const MethodChannel channel = MethodChannel('ew_monero');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
