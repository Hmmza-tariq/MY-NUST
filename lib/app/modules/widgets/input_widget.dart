import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final VoidCallback? onChanged;
  final bool isEditable;
  final bool isBorder;
  final double widthFactor;

  @override
  Widget build(BuildContext context) => Obx(
        () => SizedBox(
          width: MediaQuery.sizeOf(context).width * widthFactor,
          child: TextFormField(
            initialValue: value ??
                (doubleValue != null
                    ? doubleValue!.value.toString()
                    : stringValue!.value),
            enabled: isEditable,
            decoration: InputDecoration(
              labelText: title,
              border: isBorder ? null : InputBorder.none,
              enabledBorder: isBorder ? null : InputBorder.none,
              focusedBorder: isBorder ? null : InputBorder.none,
            ),
            keyboardType: doubleValue != null
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            onChanged: (raw) {
              if (doubleValue != null) {
                final parsed = double.tryParse(raw);
                if (parsed != null) doubleValue!.value = parsed;
              } else if (stringValue != null) {
                stringValue!.value = raw;
              }
              onChanged?.call();
            },
          ),
        ),
      );
}
