import 'package:flutter/foundation.dart';

const String _webBaseUrl = String.fromEnvironment(
  'API_BASE_URL_WEB',
  defaultValue: 'http://localhost:3000',
);
const String _mobileBaseUrl = String.fromEnvironment(
  'API_BASE_URL_MOBILE',
  defaultValue: 'http://10.0.2.2:3000',
);

String get baseUrl => kIsWeb ? _webBaseUrl : _mobileBaseUrl;

String reportsEndpoint() => '$baseUrl/reports';
String reportByIdEndpoint(String id) => '$baseUrl/reports/$id';
