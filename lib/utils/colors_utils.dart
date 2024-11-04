import 'dart:ui';

import 'package:flutter/cupertino.dart';

Color hexStringToColor(String hexColor, {double brightnessFactor = 1.0}) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }

  Color color = Color(int.parse(hexColor, radix: 16));

  HSLColor hslColor = HSLColor.fromColor(color);

  hslColor = hslColor.withLightness((hslColor.lightness * brightnessFactor).clamp(0.0, 1.0));

  return hslColor.toColor();
}
