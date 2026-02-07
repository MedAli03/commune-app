import '../models/report.dart';
import 'api_client.dart';
import 'api_config.dart';

class ReportsApi {
  ReportsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Report>> fetchReports() async {
    final data = await _client.getJsonList(reportsEndpoint());
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
}
