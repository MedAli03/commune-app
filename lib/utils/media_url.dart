import '../api/api_config.dart';

bool isAndroidEmulatedStoragePath(String value) {
  return value.startsWith('/storage/emulated/') ||
      value.contains('/storage/emulated/');
}

bool isBlockedNetworkImageUrl(String value) {
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return false;
  }
  return value.contains('/storage/emulated/');
}

bool isNetworkImageUrl(String value) {
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    return false;
  }
  return !isBlockedNetworkImageUrl(value);
}

String resolveMediaUrl(String value) {
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('/storage/') && !isAndroidEmulatedStoragePath(value)) {
    return '$baseUrl$value';
  }
  return value;
}
