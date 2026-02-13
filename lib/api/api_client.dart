import 'package:dio/dio.dart';

import 'api_config.dart';
import 'app_exception.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
      );
      return _decodeObjectBody(response.data);
    } on DioException catch (error) {
      throw _normalizeDioError(error);
    } catch (_) {
      throw AppException(message: 'Unexpected network error.');
    }
  }

  Future<List<dynamic>> getJsonList(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
      );
      return _decodeListBody(response.data);
    } on DioException catch (error) {
      throw _normalizeDioError(error);
    } catch (_) {
      throw AppException(message: 'Unexpected network error.');
    }
  }

  Future<Map<String, dynamic>> postJson(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        url,
        data: body,
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
          },
        ),
      );
      return _decodeObjectBody(response.data);
    } on DioException catch (error) {
      throw _normalizeDioError(error);
    } catch (_) {
      throw AppException(message: 'Unexpected network error.');
    }
  }

  Future<void> delete(String url) async {
    try {
      await _dio.delete<dynamic>(url);
    } on DioException catch (error) {
      throw _normalizeDioError(error);
    } catch (_) {
      throw AppException(message: 'Unexpected network error.');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String url,
    FormData formData, {
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        url,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: const {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return _decodeObjectBody(response.data);
    } on DioException catch (error) {
      throw _normalizeDioError(error);
    } catch (_) {
      throw AppException(message: 'Unexpected network error.');
    }
  }

  Map<String, dynamic> _decodeObjectBody(dynamic body) {
    if (body == null) {
      return <String, dynamic>{};
    }
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }
    throw AppException(message: 'Unexpected response format.');
  }

  List<dynamic> _decodeListBody(dynamic body) {
    if (body == null) {
      return <dynamic>[];
    }
    if (body is List) {
      return body;
    }
    throw AppException(message: 'Unexpected response format.');
  }

  AppException _normalizeDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map) {
      final mapData = Map<String, dynamic>.from(data);
      final message = mapData['message']?.toString().trim().isNotEmpty == true
          ? mapData['message'].toString()
          : _defaultStatusMessage(statusCode);
      return AppException(
        message: message,
        statusCode: statusCode,
        details: _normalizeDetails(mapData['details']),
      );
    }

    final fallbackMessage = _extractFallbackMessage(error);
    return AppException(
      message: fallbackMessage,
      statusCode: statusCode,
    );
  }

  Map<String, dynamic>? _normalizeDetails(dynamic details) {
    if (details == null) {
      return null;
    }
    if (details is Map) {
      return Map<String, dynamic>.from(details);
    }
    if (details is List) {
      return <String, dynamic>{
        'errors': details.map((item) => item.toString()).toList(),
      };
    }
    return <String, dynamic>{
      'value': details.toString(),
    };
  }

  String _extractFallbackMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }
    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!.trim();
    }
    return _defaultStatusMessage(error.response?.statusCode);
  }

  String _defaultStatusMessage(int? statusCode) {
    if (statusCode != null) {
      return 'Request failed ($statusCode).';
    }
    return 'Request failed.';
  }
}
