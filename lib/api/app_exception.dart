class AppException implements Exception {
  AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() {
    final statusPart = statusCode != null ? ' ($statusCode)' : '';
    if (details == null || details!.isEmpty) {
      return 'AppException$statusPart: $message';
    }
    return 'AppException$statusPart: $message | details: $details';
  }
}
