import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.onPressed,
    required this.color,
    required this.textColor,
    this.widthFactor,
    this.fontSize,
    this.margin,
    this.isBold,
    this.verticalPadding,
  });
  final String title;
  final void Function()? onPressed;
  final Color color;
  final Color textColor;
  final double? widthFactor;
  final double? margin;
  final double? verticalPadding;
  final double? fontSize;
  final bool? isBold;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: margin ?? 0),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: color,
              shadowColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: color)),
              fixedSize: widthFactor != null
                  ? Size.fromWidth(Get.width * widthFactor!)
                  : null,
              padding: EdgeInsets.symmetric(
                  horizontal: isBold == false ? 16 : 32,
                  vertical: verticalPadding ?? 16)),
          child: Text(title,
              style: TextStyle(
                  fontSize: fontSize ?? (isBold == false ? 14 : 18),
                  color: textColor,
                  fontWeight:
                      isBold == false ? FontWeight.normal : FontWeight.bold))),
    );
  }
}
