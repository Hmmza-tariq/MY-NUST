import 'package:google_fonts/google_fonts.dart';
import 'color_manager.dart';
import 'values_manager.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorManager.background1,
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.lightPrimary,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: ColorManager.lightGrey1,
    splashColor: ColorManager.transparent,
    highlightColor: ColorManager.transparent,

    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
          ColorManager.primaryValue, ColorManager.colorSwatch),
    ),
    dividerColor: Colors.transparent,
    // Card Theme
    cardTheme: CardTheme(
      color: ColorManager.white,
      shadowColor: ColorManager.shadow,
      elevation: 4,
      margin: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorManager.background1,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: ColorManager.shadow,
      iconTheme: IconThemeData(
        color: ColorManager.black,
      ),
      titleTextStyle: TextStyle(
        color: ColorManager.black,
        fontSize: AppSize.s16,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
      // backgroundColor: const WidgetStatePropertyAll(
      //   ColorManager.lightGrey1,
      // ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    )),
    // Button Theme
    buttonTheme: const ButtonThemeData(
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.lightPrimary,
      shape: StadiumBorder(),
      disabledColor: ColorManager.lightGrey1,
    ),
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: ColorManager.white,
        backgroundColor: ColorManager.primary,
        textStyle: GoogleFonts.poppins(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
      ),
    ),
    // Text theme
    textTheme: GoogleFonts.poppinsTextTheme(),
    // Input Decoration theme
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.all(AppPadding.p8),
      hintStyle: TextStyle(
        color: ColorManager.lightGrey2,
        fontSize: AppSize.s14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: ColorManager.lightGrey2,
        fontSize: AppSize.s14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: TextStyle(
        color: ColorManager.error,
        fontSize: AppSize.s14,
        fontWeight: FontWeight.w400,
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.lightGrey1)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.lightGrey1)),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.lightGrey1)),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ColorManager.lightGrey1)),
    ),
    dialogTheme: const DialogTheme(backgroundColor: ColorManager.background1),
    expansionTileTheme: const ExpansionTileThemeData(
      collapsedBackgroundColor: ColorManager.background1,
    ),
  );
}
