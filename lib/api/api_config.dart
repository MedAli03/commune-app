const String baseUrl = 'http://10.0.2.2:3000';

String reportsEndpoint() => '$baseUrl/reports';

String reportByIdEndpoint(String id) => '$baseUrl/reports/$id';
