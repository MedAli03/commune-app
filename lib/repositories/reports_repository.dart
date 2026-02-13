import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../api/reports_api.dart';
import '../models/report.dart';
import '../storage/hive_boxes.dart';

class ReportsRepository {
  ReportsRepository({ReportsApi? api}) : _api = api ?? ReportsApi();

  final ReportsApi _api;
  final _uuid = const Uuid();

  Future<List<Report>> fetchReportsPage({
    int page = 1,
    int perPage = 20,
    String? sortBy,
    String? sortDirection,
    String? search,
  }) async {
    return _api.fetchReports(
      page: page,
      perPage: perPage,
      sortBy: sortBy,
      sortDirection: sortDirection,
      search: search,
    );
  }

  Future<Report> fetchReportById(String id) async {
    return _api.fetchReportById(id);
  }

  Future<void> syncFromServer() async {
    try {
      final reports = await _api.fetchReports();
      final box = Hive.box<Report>(reportsBoxName);
      for (final report in reports) {
        await box.put(report.id, report);
      }
    } catch (error, stackTrace) {
      debugPrint('Sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> createReportAndSync(Report report) async {
    final box = Hive.box<Report>(reportsBoxName);
    await box.put(report.id, report);
    try {
      final syncedReport = await _api.createReport(report);
      if (syncedReport.id != report.id) {
        await box.delete(report.id);
      }
      await box.put(syncedReport.id, syncedReport);
    } catch (error, stackTrace) {
      debugPrint('Create report sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> deleteReportAndSync(String reportId) async {
    try {
      await deleteReportById(reportId);
    } catch (error, stackTrace) {
      debugPrint('Delete report sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> deleteReportById(String reportId) async {
    final box = Hive.box<Report>(reportsBoxName);
    final localReport = box.get(reportId);
    await box.delete(reportId);

    try {
      await _api.deleteReport(reportId);
    } catch (error) {
      if (localReport != null) {
        await box.put(localReport.id, localReport);
      }
      rethrow;
    }
  }

  Future<Report> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    final updated = await _api.updateReportStatus(reportId, status);
    final box = Hive.box<Report>(reportsBoxName);
    await box.put(updated.id, updated);
    return updated;
  }

  Future<Map<String, dynamic>> uploadReportImage({
    required String reportId,
    required XFile image,
    void Function(double progress)? onProgress,
  }) async {
    return _api.uploadReportImage(
      reportId,
      image,
      onSendProgress: (sent, total) {
        if (onProgress == null || total <= 0) {
          return;
        }
        onProgress(sent / total);
      },
    );
  }

  Future<void> deleteReportImage({
    required String reportId,
    required String imageId,
  }) async {
    await _api.deleteReportImage(reportId, imageId);
  }

  Future<void> runApiSmokeTest({String? sampleImagePath}) async {
    if (!kDebugMode) {
      return;
    }

    try {
      final list = await _api.fetchReports(perPage: 20);
      debugPrint('API smoke: fetched reports count=${list.length}');

      final created = await _api.createReport(
        Report(
          id: _uuid.v4(),
          title: 'Smoke test report',
          description: 'Smoke test report created from debug API check.',
          photoPath: null,
          latitude: null,
          longitude: null,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      debugPrint('API smoke: created report id=${created.id}');

      if (sampleImagePath != null && sampleImagePath.isNotEmpty) {
        final imageResponse = await _api.uploadReportImage(
          created.id,
          XFile(sampleImagePath),
        );
        debugPrint('API smoke: uploaded image response=$imageResponse');
      } else {
        debugPrint('API smoke: image upload skipped (no sample image path).');
      }
    } catch (error, stackTrace) {
      debugPrint('API smoke failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
