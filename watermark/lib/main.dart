import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _imagePath;
  ui.Image? _image;
  ui.Image? _composeImg;

  String str = '';

  @override
  void initState() {
    super.initState();
  }

  void createImage() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _image = await stringToImage(
        text: '自定义🦟🧚🏼',
        textStyle: ui.TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 48.0,
          color: Colors.red,
        ),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imagePath != null
                  ? Image.asset(_imagePath!)
                  : const Text('no select img'),
              _image != null
                  ? RawImage(image: _image, fit: BoxFit.cover)
                  : const Text('no create img'),
              _composeImg != null
                  ? RawImage(image: _composeImg!)
                  : const Text('no compose img'),
              MaterialButton(
                onPressed: openGallery,
                child: const Text('第一步 选择图片'),
              ),
              TextField(
                onChanged: (text) {
                  str = text;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '第二步 输入你想转换的的字符',
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  _image = await stringToImage(
                    text: str,
                    textStyle: ui.TextStyle(fontSize: 48, color: Colors.blue),
                  );
                  setState(() {});
                },
                child: const Text('生成水印'),
              ),
              MaterialButton(
                onPressed: () async {
                  _image = await stringToImage(
                    text: str,
                    textStyle: ui.TextStyle(fontSize: 48, color: Colors.blue),
                  );
                  composeImage();
                },
                child: const Text('第三步 给你选择的图片加上字符水印'),
              ),
              MaterialButton(
                onPressed: composeImage,
                child: const Text('合成图片'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openGallery() async {
    PermissionStatus permissionStatus;
    bool allow = true;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permissionStatus = await Permission.photos.status;
        if (permissionStatus != PermissionStatus.granted) {
          allow = false;
        } else {
          allow = true;
        }
      } else {
        permissionStatus = await Permission.storage.status;
        if (permissionStatus != PermissionStatus.granted) {
          allow = false;
        } else {
          allow = true;
        }
      }
    } else {
      permissionStatus = await Permission.photos.request();
      if (permissionStatus != PermissionStatus.granted) {
        allow = false;
      } else {
        allow = true;
      }
    }
    if (allow) {
      XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        _imagePath = file.path;
        setState(() {});
      }
    } else {
      // showOpenSettingDialog(tip: '您未开启相册权限，请先授予相册权限');
      debugPrint('您未开启相册权限，请先授予相册权限');
    }
  }

  void saveImage({required Uint8List imageData}) async {
    final result = await ImageGallerySaver.saveImage(
      imageData,
      quality: 100,
    );
    final isSuccess = result['isSuccess'];
    debugPrint(isSuccess ? '保存成功' : '保存失败');
  }

  Future<ui.Image> stringToImage1({
    required String text,
    required String targetImagePath,
  }) async {
    final originByteData = await rootBundle.load(_imagePath!);
    final targetImg = img.decodeImage(originByteData.buffer.asUint8List());
    var font = img.arial48;
    font.size = 64;
    final tempImg = img.drawString(
      targetImg!,
      text,
      font: font,
      color: img.ColorInt16.rgba(24, 134, 146, 1),
      x: 0,
      y: 20,
    );
    final newImg = img.copyResize(tempImg, width: tempImg.width * 4);
    final newImage = await convert(image: newImg);
    return newImage;
  }

  // 将文本转换为图片
  Future<ui.Image> stringToImage({
    required String text,
    required ui.TextStyle textStyle,
  }) async {
    // 获取屏幕尺寸
    Size size = MediaQuery.of(context).size;
    // 创建绘图记录器
    final picRecorder = ui.PictureRecorder();
    // 创建段落构建器
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle());
    // 设置段落样式
    paragraphBuilder.pushStyle(textStyle);
    // 添加文本
    paragraphBuilder.addText(text);
    // 构建段落
    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size.width));
    // 计算行高
    final lineMetrics = paragraph.computeLineMetrics();
    // 计算最大宽度
    var width = 0.0;
    for (var element in lineMetrics) {
      if (element.width > width) {
        width = element.width;
      }
    }
    // 创建画布
    final cvs =
        Canvas(picRecorder, Rect.fromLTRB(0, 0, width, paragraph.height));
    // 绘制段落
    cvs.drawParagraph(paragraph, const Offset(0.0, 0.0));
    // 结束绘图记录
    final pic = picRecorder.endRecording();
    // 将绘图记录转换为图片
    final img = await pic.toImage(width.toInt(), paragraph.height.toInt());
    return img;
  }


  /// 将两张图片合成一张图片。
  /// 此函数首先从给定的路径加载原始图片，然后加载要合成的图片，
  /// 对加载的图片进行处理（如调整大小），并将它们合成在一起，
  /// 最后将合成后的图片保存，并更新UI显示。
  ///
  /// @async 表示此函数为异步函数。
  void composeImage() async {
    // 加载原始图片的字节数据
    final originByteData = await rootBundle.load(_imagePath!);
    // 加载要合成的图片的字节数据
    final srcByteData =
    await _image!.toByteData(format: ui.ImageByteFormat.png);
    // 解码原始图片
    final originImg = img.decodeImage(originByteData.buffer.asUint8List());
    // 解码要合成的图片
    var srcImg = img.decodeImage(srcByteData!.buffer.asUint8List());
    // 调整要合成的图片的大小
    srcImg = img.copyResize(srcImg!, width: srcImg.width * 4);
    // 合成图片
    final newImg = img.compositeImage(
      originImg!,
      srcImg,
      center: true,
    );
    // 将合成后的图片转换为指定格式并保存
    _composeImg = await convert(image: newImg);
    // 更新UI
    setState(() {});
  }

  /// 将给定的img.Image对象转换为ui.Image对象。
  ///
  /// @param image 必需，img.Image对象，待转换的图像。
  /// @return 返回一个Future，该Future解析为ui.Image对象，表示转换后的图像。
  Future<ui.Image> convert({required img.Image image}) async {
    // 创建img.Command对象用于图像处理
    final cmd = img.Command();
    // 设置待处理的图像
    cmd.image(image);
    // 指定图像编码为PNG
    cmd.encodePng();
    // 在独立线程中获取图像的字节数据
    final bytes = await cmd.getBytesThread();
    // 使用字节数据解码为ui.Image对象
    final newImage = await uiImageDecode(bytes!);
    return newImage!;
  }


   /// 异步解码图像数据。
  ///
  /// @param list 一个Uint8List类型的图像数据列表。
  /// @return 返回一个Future，该Future解析为ui.Image类型的图像对象。如果解码失败，则返回null。
  Future<ui.Image?> uiImageDecode(Uint8List list) async {
    // 创建一个Completer来处理异步图像解码结果
    Completer<ui.Image> completer = Completer();

    // 使用ui.decodeImageFromList异步解码图像数据，并在解码完成后通过Completer完成
    ui.decodeImageFromList(list, (ui.Image callBack) {
      completer.complete(callBack);
    });

    // 返回Completer的Future，等待解码完成
    return completer.future;
  }

}
