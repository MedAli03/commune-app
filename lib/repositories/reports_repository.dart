import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../api/reports_api.dart';
import '../models/report.dart';
import '../storage/hive_boxes.dart';

class ReportsRepository {
  ReportsRepository({ReportsApi? api}) : _api = api ?? ReportsApi();

  final ReportsApi _api;

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
}
