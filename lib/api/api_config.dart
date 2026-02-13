const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

const String reportsPath = '/reports';

String reportsEndpoint() => reportsPath;
String reportByIdEndpoint(String id) => '$reportsPath/$id';
String reportImagesEndpoint(String reportId) => '$reportsPath/$reportId/images';
String reportImageByIdEndpoint(String reportId, String imageId) =>
    '${reportImagesEndpoint(reportId)}/$imageId';
