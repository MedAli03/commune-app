import 'package:flutter/foundation.dart';

const String _webBaseUrl = 'http://localhost:3000';
const String _mobileBaseUrl = 'http://10.0.2.2:3000';

String baseUrl = kIsWeb ? _webBaseUrl : _mobileBaseUrl;
