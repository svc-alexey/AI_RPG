import 'package:flutter/material.dart';

Widget buildPortraitImage({
  required final String portraitPath,
  required final BoxFit fit,
  required final double width,
  required final double height,
  required final Widget Function(BuildContext, Object, StackTrace?)
  errorBuilder,
}) => Image.asset(
  portraitPath,
  fit: fit,
  width: width,
  height: height,
  errorBuilder: errorBuilder,
);
