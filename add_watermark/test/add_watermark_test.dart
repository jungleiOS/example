import 'package:flutter_test/flutter_test.dart';
import 'package:add_watermark/add_watermark.dart';
import 'package:add_watermark/add_watermark_platform_interface.dart';
import 'package:add_watermark/add_watermark_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAddWatermarkPlatform
    with MockPlatformInterfaceMixin
    implements AddWatermarkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AddWatermarkPlatform initialPlatform = AddWatermarkPlatform.instance;

  test('$MethodChannelAddWatermark is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAddWatermark>());
  });

  test('getPlatformVersion', () async {
    AddWatermark addWatermarkPlugin = AddWatermark();
    MockAddWatermarkPlatform fakePlatform = MockAddWatermarkPlatform();
    AddWatermarkPlatform.instance = fakePlatform;

    expect(await addWatermarkPlugin.getPlatformVersion(), '42');
  });
}
