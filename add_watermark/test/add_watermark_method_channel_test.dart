import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:add_watermark/add_watermark_method_channel.dart';

void main() {
  MethodChannelAddWatermark platform = MethodChannelAddWatermark();
  const MethodChannel channel = MethodChannel('add_watermark');

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
