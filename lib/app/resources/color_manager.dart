import 'package:flutter/material.dart';

class ColorManager {
  static const Map<int, Color> colorSwatch = {
    50: Color.fromRGBO(0, 98, 255, .1), // Lightest Primary
    100: Color.fromRGBO(0, 98, 255, .2),
    200: Color.fromRGBO(0, 98, 255, .3),
    300: Color.fromRGBO(0, 98, 255, .4),
    400: Color.fromRGBO(0, 98, 255, .5),
    500: Color.fromRGBO(0, 98, 255, .6),
    600: Color.fromRGBO(0, 98, 255, .7),
    700: Color.fromRGBO(0, 98, 255, .8),
    800: Color.fromRGBO(0, 98, 255, .9),
    900: Color.fromRGBO(0, 98, 255, 1), // Darkest Primary
  };

  static const primaryValue = 0xFF0062FF; // Primary color
  static const Color primary = Color(0xFF0062FF); // Primary color
  static const Color background1 = Color(0xFFF2F2F2); // Background color 1
  static const Color background2 = Color(0xFFFFFFFF); // Background color 2
  static const Color secondary = Color(0xFFAAAACF); // Secondary color

  static const Color lightPrimary = Color(0xFF4D8CFF); // Light Primary
  static const Color lightestPrimary = Color(0xFFB2C8FF); // Lightest Primary
  static const Color darkPrimary = Color(0xFF0051CC); // Dark Primary
  static const Color primary50 = Color(0xFFE0ECFF); // Very light Primary
  static const Color primary500 = Color(0xFF0062FF); // Primary

  static const Color green = Color(0xFF14A15A); // Green
  static const Color lightGreen = Color(0xFFD9FBE7); // Light Green

  static const Color yellow = Color(0xFFFFD700); // Gold
  static const Color lightYellow = Color(0xFFFFF8DC); // Light Yellow

  static const Color orange = Color(0xFFFFA500); // Orange
  static const Color pink = Color(0xFFFF69B4); // Pink
  static const Color cyan = Colors.cyan;

  static const Color darkGrey = Color(0xFF232323); // Dark Grey (almost black)

  static const Color lightestGrey = Color(0xFFF3F5F7); // Very light Grey
  static const Color lightGrey =
      Color(0x9F8B94AC); // Light Grey with transparency
  static const Color lightGrey1 = Color(0xFFE2E3F1); // Light Grey
  static const Color lightGrey2 = Color(0xFF64748B); // Medium Grey
  static const Color lightGrey3 = Color(0xFF8d8d8d); // Darker Grey

  static const Color error = Color(0xFFD8464D); // Error
  static const Color lightError = Color(0xFFFFEBEC); // Light Error

  static const Color warning = Color(0xFFFDB022); // Warning

  static const Color transparent =
      Color.fromARGB(0, 255, 255, 255); // Transparent
  static const Color white = Color.fromARGB(255, 255, 255, 255); // White
  static const Color black = Color(0xFF000000); // Black
  static const Color shadow = Color.fromARGB(100, 180, 209, 209); // Shadow

  static final gradientColor = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: List.generate(5, (index) => primary.withOpacity(0.1 * (index + 1))),
  );

  static const Color textColor = black;

  static const primaryShadow = BoxShadow(
    color: Color(0xffB4D1D1),
    blurRadius: 60,
    offset: Offset(0, 30),
  );
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = "FF$hexColorString";
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
