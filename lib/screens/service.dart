import 'dart:io';

import 'package:dio/dio.dart';

class HttpService {
  Future sendImage(File file) async {
    FormData formData =
        FormData.fromMap({"image": await MultipartFile.fromFile(file.path)});
    return Dio().post('http://192.168.1.3:5000/frame', data: formData);
  }
}
