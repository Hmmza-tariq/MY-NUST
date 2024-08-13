import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.onPressed,
    required this.color,
    required this.textColor,
    required this.widthFactor,
    this.margin,
    this.isBold,
  });
  final String title;
  final void Function()? onPressed;
  final Color color;
  final Color textColor;
  final double widthFactor;
  final double? margin;
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: color)),
              fixedSize: Size.fromWidth(Get.width * widthFactor),
              padding: EdgeInsets.symmetric(
                  horizontal: isBold == false ? 16 : 32, vertical: 16)),
          child: Text(title,
              style: TextStyle(
                  fontSize: isBold == false ? 14 : 18,
                  color: textColor,
                  fontWeight:
                      isBold == false ? FontWeight.normal : FontWeight.bold))),
    );
  }
}
