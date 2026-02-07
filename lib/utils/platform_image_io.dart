import 'dart:io';

import 'package:flutter/material.dart';

Widget? buildPlatformImageImpl(
  String path, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
}) {
  return Image.file(
    File(path),
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
  );
}

bool platformFileExistsImpl(String path) => File(path).existsSync();
