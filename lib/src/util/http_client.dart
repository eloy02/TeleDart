/**
 * TeleDart - Telegram Bot API for Dart
 * Copyright (C) 2019  Dino PH Leung
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class HttpClient {
  /// HTTP get method
  /// [url] request url with query string (required)
  Future<dynamic> httpGet(String url, {String proxy}) async {
    var dio = _initializeClient(proxy: proxy);

    return dio.get(url).then((response) {
      Map<String, dynamic> body = jsonDecode(response.data);
      if (body['ok']) {
        return body['result'];
      } else {
        return Future.error(HttpClientException(
            '${body['error_code']} ${body['description']}'));
      }
    }).catchError((error) => Future.error(HttpClientException('${error}')));
  }

  /// HTTP post method (x-www-form-urlencoded)
  /// [url] - request url (required)
  /// [body] - parameters in map
  Future<dynamic> httpPost(String url,
      {String proxy, Map<String, dynamic> body}) async {
    var dio = _initializeClient(proxy: proxy);

    return dio
        .post(url, data: body.map((k, v) => MapEntry(k, '${v}')))
        .then((response) {
      Map<String, dynamic> responseBody = jsonDecode(response.data);
      if (responseBody['ok']) {
        return responseBody['result'];
      } else {
        return Future.error(HttpClientException(
            '${responseBody['error_code']} ${responseBody['description']}'));
      }
    }).catchError((error) => Future.error(HttpClientException('${error}')));
  }

  /// HTTP post method (multipart/form-data)
  /// [url] - request url (required)
  /// [file] - file to upload (required)
  /// [body] - parameters in map
  Future<dynamic> httpMultipartPost(String url, List<MultipartFile> files,
      {Map<String, dynamic> body, String proxy}) async {
    var dio = _initializeClient(
        proxy: proxy /*, headers: {'Content-Type': 'multipart/form-data'}*/);

    var data = FormData.fromMap(body.map((k, v) => MapEntry(k, '${v}'))
      ..addAll({
        'files': [files]
      }));

    return dio.post(url, data: data).then((response) {
      Map<String, dynamic> responseBody = jsonDecode(response.data);
      if (responseBody['ok']) {
        return responseBody['result'];
      } else {
        return Future.error(HttpClientException(
            '${responseBody['error_code']} ${responseBody['description']}'));
      }
    }).catchError((error) => Future.error(HttpClientException('${error}')));
  }

  Future<dynamic> httpFormDataPost(String url, FormData formData,
      {String proxy}) {
    var dio = _initializeClient(proxy: proxy);
    return dio.post(url, data: formData).then((response) {
      Map<String, dynamic> responseBody = jsonDecode(response.data);
      if (responseBody['ok']) {
        return responseBody['result'];
      } else {
        return Future.error(HttpClientException(
            '${responseBody['error_code']} ${responseBody['description']}'));
      }
    }).catchError((error) => Future.error(HttpClientException('${error}')));
  }

  Dio _initializeClient({String proxy, Map<String, dynamic> headers}) {
    var dio = Dio();

    if (proxy.isNotEmpty) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) => proxy;
      };
    }

    if (headers.isNotEmpty) {
      dio.options.headers.addAll(headers);
    }

    return dio;
  }
}

class HttpClientException implements Exception {
  String cause;
  HttpClientException(this.cause);
  @override
  String toString() => 'HttpClientException: ${cause}';
}
