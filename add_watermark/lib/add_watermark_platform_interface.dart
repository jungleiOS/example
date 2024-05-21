import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'add_watermark_method_channel.dart';

abstract class AddWatermarkPlatform extends PlatformInterface {
  /// Constructs a AddWatermarkPlatform.
  AddWatermarkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AddWatermarkPlatform _instance = MethodChannelAddWatermark();

  /// The default instance of [AddWatermarkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAddWatermark].
  static AddWatermarkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AddWatermarkPlatform] when
  /// they register themselves.
  static set instance(AddWatermarkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
