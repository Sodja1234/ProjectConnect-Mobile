// lib/framework/utils/http/remoteHttpUtils.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';
import 'package:odc_mobile_template/utils/http/HttpUtils.dart';

class RemoteHttpUtils implements HttpUtils {
  final Dio _dio;
  final CookieJar _cookieJar;

  RemoteHttpUtils()
      : _dio = Dio(),
        _cookieJar = CookieJar() {
    _dio.interceptors.add(CookieManager(_cookieJar));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          // Ancien code: (options.extra['customHeaders'] as Map<String, String>).forEach(...)
          // Nouveau code: Vérifier explicitement si c'est un Map et non null
          if (options.extra.containsKey('customHeaders')) {
            final dynamic customHeaders = options.extra['customHeaders'];
            if (customHeaders is Map<String, String>) { // Vérifier le type avant le cast/forEach
              customHeaders.forEach((key, value) {
                options.headers[key] = value;
              });
            }
          }

          if (options.extra.containsKey('token') && options.extra['token'] != null) {
            options.headers['Authorization'] = 'Bearer ${options.extra['token']}';
          }

          if (['POST', 'PUT', 'PATCH', 'DELETE'].contains(options.method) &&
              !options.path.contains('/sanctum/csrf-cookie')) {
            List<Cookie> cookies = await _cookieJar.loadForRequest(options.uri);
            String? xsrfToken;
            for (var cookie in cookies) {
              if (cookie.name == 'XSRF-TOKEN') {
                xsrfToken = Uri.decodeComponent(cookie.value);
                break;
              }
            }
            if (xsrfToken != null) {
              options.headers['X-XSRF-TOKEN'] = xsrfToken;
              print('CSRF: Sending X-XSRF-TOKEN for ${options.path}');
            } else {
              print('CSRF: XSRF-TOKEN not found for ${options.path}.');
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response != null) {
            final int statusCode = e.response!.statusCode ?? -1;
            final String? body = e.response!.data != null
                ? (e.response!.data is String ? e.response!.data : jsonEncode(e.response!.data))
                : null;
            throw HttpRequestException(statusCode, e.message ?? 'Unknown error', body);
          } else {
            throw HttpRequestException(-1, e.message ?? 'Network error', null);
          }
        },
      ),
    );
  }

  @override
  Future<String> getData(
      String url, {
        Map<String, String>? headers, // Ce paramètre peut être null
        Map<String, dynamic>? queryParams,
        String? token, // Ce paramètre peut être null
      }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          // Ici, nous passons `headers` et `token` qui peuvent être null
          extra: {'customHeaders': headers, 'token': token},
        ),
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data is Map || response.data is List) {
          return jsonEncode(response.data);
        }
        return response.data?.toString() ?? '';
      } else {
        throw HttpRequestException(
          response.statusCode!,
          response.statusMessage ?? 'Unknown status',
          response.data?.toString(),
        );
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  // ... (postData et putData restent inchangés car ils ont déjà un bon comportement avec body: null)
  @override
  Future<dynamic> postData(
      String url, {
        Map<String, String>? headers,
        String? token,
        Map<String, dynamic>? body,
      }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(extra: {'customHeaders': headers, 'token': token}),
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        throw HttpRequestException(
          response.statusCode!,
          response.statusMessage ?? 'Unknown status',
          response.data?.toString(),
        );
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> putData(
      String url, {
        Map<String, String>? headers,
        String? token,
        Map<String, dynamic>? body,
      }) async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        options: Options(extra: {'customHeaders': headers, 'token': token}),
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        throw HttpRequestException(
          response.statusCode!,
          response.statusMessage ?? 'Unknown status',
          response.data?.toString(),
        );
      }
    } on DioException catch (e) {
      rethrow;
    }
  }
}