
import 'add_watermark_platform_interface.dart';

class AddWatermark {
  Future<String?> getPlatformVersion() {
    return AddWatermarkPlatform.instance.getPlatformVersion();
  }
}
