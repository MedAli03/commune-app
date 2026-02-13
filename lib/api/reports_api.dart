import '../models/report.dart';
import 'api_client.dart';
import 'api_config.dart';

class ReportsApi {
  ReportsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Report>> fetchReports({
    int? page,
    int? perPage,
    String? sortBy,
    String? sortDirection,
    String? search,
  }) async {
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (perPage != null) 'perPage': perPage,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
      if (search != null && search.isNotEmpty) 'search': search,
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
}
