import 'dart:io';

import 'package:flutter/material.dart';

Widget buildPortraitImage({
  required final String portraitPath,
  required final BoxFit fit,
  required final double width,
  final double? height,
  required final Widget Function(BuildContext, Object, StackTrace?)
  errorBuilder,
}) => Image.file(
  File(portraitPath),
  fit: fit,
  width: width,
  height: height,
  errorBuilder: errorBuilder,
);
