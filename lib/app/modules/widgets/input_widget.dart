import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';
import '../../resources/color_manager.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    super.key,
    this.doubleValue,
    this.stringValue,
    this.value,
    required this.title,
    this.onChanged,
    this.isEditable = true,
    this.isBorder = true,
    this.widthFactor = 1,
  });

  final RxDouble? doubleValue;
  final RxString? stringValue;
  final String title;
  final String? value;
  final void Function()? onChanged;
  final bool isEditable;
  final bool isBorder;
  final double widthFactor;
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() => SizedBox(
          width: Get.width * widthFactor,
          child: TextFormField(
            initialValue: value ??
                (doubleValue != null
                    ? doubleValue!.value.toString()
                    : stringValue!.value),
            enabled: isEditable,
            decoration: InputDecoration(
              labelText: title,
              border: !isBorder
                  ? null
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: !themeController.isDarkMode.value
                            ? ColorManager.primary
                            : ColorManager.lightGrey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
              enabledBorder: !isBorder
                  ? null
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: !themeController.isDarkMode.value
                            ? ColorManager.primary
                            : ColorManager.lightGrey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
              focusedBorder: !isBorder
                  ? null
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                        color: themeController.isDarkMode.value
                            ? ColorManager.primary
                            : ColorManager.lightGrey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
              labelStyle: TextStyle(
                color: !themeController.isDarkMode.value
                    ? ColorManager.primary
                    : ColorManager.lightGrey3,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextStyle(
              color: !themeController.isDarkMode.value
                  ? ColorManager.black
                  : ColorManager.white,
            ),
            keyboardType:
                doubleValue != null ? TextInputType.number : TextInputType.text,
            onChanged: (val) {
              if (doubleValue != null) {
                double? weight = double.tryParse(val);
                if (weight != null) {
                  doubleValue!.value = weight;
                }
              } else if (stringValue != null) {
                stringValue!.value = val;
              }
              if (onChanged != null) onChanged!();
            },
          ),
        ));
  }
}
