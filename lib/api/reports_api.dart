import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'app_exception.dart';

class ReportsApi {
  ReportsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Report>> fetchReports({
    int? page,
    int? perPage,
    String? sortBy,
    String? sortDirection,
    String? search,
    String? status,
  }) async {
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (perPage != null) 'perPage': perPage,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final data = await _client.getJsonList(
      reportsEndpoint(),
      queryParameters: query.isEmpty ? null : query,
    );
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(Report.fromJson)
        .toList();
  }

  Future<Report> fetchReportById(String id) async {
    final data = await _client.getJson(reportByIdEndpoint(id));
    return Report.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Report> createReport(Report report) async {
    final data = await _client.postJson(reportsEndpoint(), report.toJson());
    return Report.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteReport(String id) async {
    await _client.delete(reportByIdEndpoint(id));
  }

  Future<Report> updateReportStatus(String id, String status) async {
    final data = await _client.patchJson(reportStatusEndpoint(id), {
      'status': status,
    });
    return Report.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>> uploadReportImage(
    String reportId,
    XFile image, {
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      return await _uploadReportImageWithField(
        reportId: reportId,
        image: image,
        fieldName: 'image',
        onSendProgress: onSendProgress,
      );
    } on AppException catch (error) {
      final shouldFallback = error.statusCode == 400 ||
          error.statusCode == 422 ||
          error.message.toLowerCase().contains('image');
      if (!shouldFallback) {
        rethrow;
      }

      return _uploadReportImageWithField(
        reportId: reportId,
        image: image,
        fieldName: 'file',
        onSendProgress: onSendProgress,
      );
    }
  }

  Future<void> deleteReportImage(String reportId, String imageId) async {
    await _client.delete(reportImageByIdEndpoint(reportId, imageId));
  }

  Future<Map<String, dynamic>> _uploadReportImageWithField({
    required String reportId,
    required XFile image,
    required String fieldName,
    void Function(int, int)? onSendProgress,
  }) async {
    final fileName = image.name.isNotEmpty ? image.name : 'upload.jpg';
    final multipart = await MultipartFile.fromFile(
      image.path,
      filename: fileName,
    );
    final formData = FormData.fromMap({
      fieldName: multipart,
    });

    return _client.postMultipart(
      reportImagesEndpoint(reportId),
      formData,
      onSendProgress: onSendProgress,
    );
  }
}
