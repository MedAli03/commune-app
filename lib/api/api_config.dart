import 'package:flutter/foundation.dart';

// Update these base URLs for your deployed backend.
const String _webBaseUrl = 'http://localhost:3000';
const String _mobileBaseUrl = 'http://10.0.2.2:3000';

String get baseUrl => kIsWeb ? _webBaseUrl : _mobileBaseUrl;

String reportsEndpoint() => '$baseUrl/reports';
String reportByIdEndpoint(String id) => '$baseUrl/reports/$id';
String deleteReportEndpoint(String id) => '$baseUrl/reports/$id';
