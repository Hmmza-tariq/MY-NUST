import 'package:flutter/material.dart';

class ColorManager {
  static const Map<int, Color> colorSwatch = {
    50: Color.fromRGBO(0, 98, 255, .1),
    100: Color.fromRGBO(0, 98, 255, .2),
    200: Color.fromRGBO(0, 98, 255, .3),
    300: Color.fromRGBO(0, 98, 255, .4),
    400: Color.fromRGBO(0, 98, 255, .5),
    500: Color.fromRGBO(0, 98, 255, .6),
    600: Color.fromRGBO(0, 98, 255, .7),
    700: Color.fromRGBO(0, 98, 255, .8),
    800: Color.fromRGBO(0, 98, 255, .9),
    900: Color.fromRGBO(0, 98, 255, 1),
  };

  static const primaryValue = 0xFF0062FF;
  static const Color primary = Color(0xFF0062FF);
  static const Color background1 = Color(0xFFF2F2F2);
  static const Color background2 = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFAAAACF);

  static const Color lightPrimary = Color(0xFF4D8CFF);
  static const Color lightestPrimary = Color(0xFFB2C8FF);
  static const Color darkPrimary = Color(0xFF0051CC);
  static const Color primary50 = Color(0xFFE0ECFF);
  static const Color primary500 = Color(0xFF0062FF);

  static const Color green = Color(0xFF14A15A);
  static const Color lightGreen = Color(0xFFD9FBE7);

  static const Color yellow = Color(0xFFFFD700);
  static const Color lightYellow = Color(0xFFFFF8DC);

  static const Color orange = Color(0xFFFFA500);
  static const Color pink = Color(0xFFFF69B4);
  static const Color cyan = Colors.cyan;

  static const Color darkGrey = Color(0xFF232323);

  static const Color lightestGrey = Color(0xFFF3F5F7);
  static const Color lightGrey = Color(0x9F8B94AC);
  static const Color lightGrey1 = Color(0xFFE2E3F1);
  static const Color lightGrey2 = Color(0xFF64748B);
  static const Color lightGrey3 = Color(0xFF8d8d8d);

  static const Color error = Color(0xFFD8464D);
  static const Color lightError = Color(0xFFFFEBEC);

  static const Color warning = Color(0xFFFDB022);

  static const Color transparent = Color.fromARGB(0, 255, 255, 255);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color black = Color(0xFF000000);
  static const Color shadow = Color.fromARGB(100, 180, 209, 209);

  static const Color textColor = black;

  static const primaryShadow = BoxShadow(
    color: Color(0xffB4D1D1),
    blurRadius: 60,
    offset: Offset(0, 30),
  );

  static const Color backgroundDark = Color(0xFF1E1E1E);
  static const Color primaryDark = Color(0xFF0051AA);
  static const Color darkGrey1 = Color(0xFF2A2A2A);
  static const Color darkCard = Color(0xFF333333);
  static const Color darkShadow = Color.fromARGB(100, 60, 60, 60);
  static const Color darkGrey2 = Color(0xFF3D3D3D);
  static const Color errorDark = Color(0xFFCF6679);

  static final gradientColor = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: List.generate(5, (index) => primary.withOpacity(0.1 * (index + 1))),
  );
}
