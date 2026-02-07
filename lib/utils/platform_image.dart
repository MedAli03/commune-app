import 'package:flutter/material.dart';

import 'platform_image_stub.dart'
    if (dart.library.io) 'platform_image_io.dart';

Widget? buildPlatformImage(
  String path, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
}) {
  return buildPlatformImageImpl(
    path,
    height: height,
    width: width,
    fit: fit,
  );
}

bool platformFileExists(String path) => platformFileExistsImpl(path);
