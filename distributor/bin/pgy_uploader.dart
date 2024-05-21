import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

// 蒲公英工具类
class PGYTool {
  final getTokenPath = 'https://www.pgyer.com/apiv2/app/getCOSToken';
  final getAppInfoPath = 'https://www.pgyer.com/apiv2/app/buildInfo';
  final String apiKey;
  final String buildType; //android、ios

  PGYTool({
    required this.apiKey,
    required this.buildType,
  });

  //发布应用
  Future<bool> publish(String appFilePath) async {
    final dio = Dio();
    stdout.write('开始获取蒲公英token');
    final tokenResponse = await _getToken(dio);
    if (tokenResponse == null) {
      stdout.write('>>>>>> 获取token失败 \n');
      return false;
    }
    stdout.write('>>>>>> 获取token成功 \n');
    final endpoint = tokenResponse['data']['endpoint'] ?? '';
    final params = tokenResponse['data']['params'] ?? {};
    stdout.write('蒲公英上传地址：$endpoint\n');
    Map<String, dynamic> map = {
      ...params,
    };
    map['file'] = await MultipartFile.fromFile(appFilePath);
    final controller = StreamController<MapEntry<int, int>>();
    controller.stream
        .throttleTime(const Duration(seconds: 1), trailing: true)
        .listen(
          (event) => stdout.write(
        '${event.key}/${event.value}  ${(event.key.toDouble() / event.value.toDouble() * 100).toStringAsFixed(2)}% \n',
      ),
      onDone: () {
        controller.close();
      },
      onError: (e) {
        controller.close();
      },
    );
    final uploadRsp = await dio.post(
      endpoint,
      data: FormData.fromMap(map),
      onSendProgress: (count, total) {
        controller.sink.add(
          MapEntry<int, int>(
            count,
            total,
          ),
        );
      },
    );
    await Future.delayed(const Duration(seconds: 1));
    if (uploadRsp.statusCode != 204) {
      stdout.write('>>>>> 蒲公英上传失败 \n');
      return false;
    }
    stdout.write('>>>>> 蒲公英上传成功 \n');
    await Future.delayed(const Duration(seconds: 3));
    await _getAppInfo(dio, tokenResponse['data']['key']);
    return true;
  }

  // 获取蒲公英token
  Future<Map<String, dynamic>?> _getToken(Dio dio) async {
    Response<Map<String, dynamic>>? tokenResponse;
    try {
      tokenResponse = await dio.post<Map<String, dynamic>>(
        getTokenPath,
        queryParameters: {
          '_api_key': apiKey,
          'buildType': buildType,
        },
      );
    } catch (_) {
      stdout.write('_getToken error : $_');
    }
    if (tokenResponse == null) return null;
    final responseJson = tokenResponse.data ?? {};
    final tokenCode = responseJson['code'] ?? 100;
    if (tokenCode != 0) {
      return null;
    } else {
      return responseJson;
    }
  }

  // tokenKey 是获取token中的返回值Key
  Future<void> _getAppInfo(Dio dio, String tokenKey, {int retryCount = 3}) async {
    final response = await dio.get<Map<String, dynamic>>(
      getAppInfoPath,
      queryParameters: {
        '_api_key': apiKey,
        'buildKey': tokenKey,
      },
    ).then((value) {
      return value.data ?? {};
    });
    final responseCode = response['code'];
    if (responseCode == 1247 && retryCount > 0) {
      //应用正在发布中，间隔 3 秒重新获取
      stdout.write('>>>>> 应用正在发布中，间隔 3 秒重新获取发布信息\n');
      await Future.delayed(const Duration(seconds: 3));
      return _getAppInfo(dio, tokenKey, retryCount: retryCount - 1);
    }
    final appName = response['data']['buildName'];
    final appVersion = response['data']['buildVersion'];
    final appUrl = response['data']['buildShortcutUrl'];
    final updateTime = response['data']['buildUpdated'];
    if (appName != null) {
      stdout.write('$appName 版本更新（$appVersion）\n');
      stdout.write('下载地址：https://www.pgyer.com/$appUrl\n');
      stdout.write('更新时间：$updateTime\n');
    }
  }
}
