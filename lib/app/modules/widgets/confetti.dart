import 'dart:math';

import 'package:flutter/material.dart';

Path drawHexagons(Size size) {
  final path = Path();
  double width = size.width;
  double height = size.height;
  double hexagonRadius = width * 0.25;
  double centerX = width * 0.5;
  double centerY = height * 0.5;

  // Draw a hexagon
  for (int i = 0; i < 6; i++) {
    double angle = (i * 60.0) * (3.141592653589793 / 180.0);
    double x = centerX + hexagonRadius * cos(angle);
    double y = centerY + hexagonRadius * sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}
