const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

String reportsEndpoint() => '$baseUrl/reports';
String reportByIdEndpoint(String id) => '$baseUrl/reports/$id';
