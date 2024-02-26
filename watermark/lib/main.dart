import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
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

  @override
  void initState() {
    super.initState();
    createImage();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
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
              child: const Text('选择图片'),
            ),
            MaterialButton(
              onPressed: composeImage,
              child: const Text('合成图片'),
            ),
          ],
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

  Future<ui.Image> stringToImage({
    required String text,
    required ui.TextStyle textStyle,
  }) async {
    Size size = MediaQuery.of(context).size;
    final picRecorder = ui.PictureRecorder();
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle());
    paragraphBuilder.pushStyle(textStyle);
    paragraphBuilder.addText(text);
    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size.width));
    final lineMetrics = paragraph.computeLineMetrics();
    var width = 0.0;
    for (var element in lineMetrics) {
      if (element.width > width) {
        width = element.width;
      }
    }
    final cvs =
        Canvas(picRecorder, Rect.fromLTRB(0, 0, width, paragraph.height));
    cvs.drawParagraph(paragraph, const Offset(0.0, 0.0));
    final pic = picRecorder.endRecording();
    final img = await pic.toImage(width.toInt(), paragraph.height.toInt());
    return img;
  }

  void composeImage() async {
    final originByteData = await rootBundle.load(_imagePath!);
    final srcByteData =
        await _image!.toByteData(format: ui.ImageByteFormat.png);
    final originImg = img.decodeImage(originByteData.buffer.asUint8List());
    final srcImg = img.decodeImage(srcByteData!.buffer.asUint8List());
    final newImg = img.compositeImage(
      originImg!,
      srcImg!,
      center: true,
    );
    final cmd = img.Command();
    cmd.image(newImg);
    cmd.encodePng();
    debugPrint('合成图片正在编码并转换为uint8List ...');
    final uint8List = await cmd.getBytesThread();
    debugPrint('编码转换完成');
    _composeImg = await _fun2(uint8List!);
    /// 下面这种方法会阻塞UI线程导致卡顿
    // final uint8List = img.encodePng(newImg);
    // _composeImg = await _fun2(img.encodePng(newImg));
    setState(() {});
  }


  Future<ui.Image?> _fun2(Uint8List list) async {
    Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(list, (ui.Image callBack) {
      completer.complete(callBack);
    });
    return completer.future;
  }
}
