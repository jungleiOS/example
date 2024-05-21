import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'add_watermark_platform_interface.dart';

/// An implementation of [AddWatermarkPlatform] that uses method channels.
class MethodChannelAddWatermark extends AddWatermarkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('add_watermark');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
