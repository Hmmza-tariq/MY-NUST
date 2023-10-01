import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:mynust/Core/app_theme.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key, required this.isLightMode});
  final bool isLightMode;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InfoPopupWidget(
        contentOffset: const Offset(0, 0),
        arrowTheme: InfoPopupArrowTheme(
          arrowDirection: ArrowDirection.up,
          color: isLightMode
              ? const Color.fromARGB(255, 199, 199, 199)
              : const Color.fromARGB(255, 1, 54, 98),
        ),
        contentTheme: InfoPopupContentTheme(
          infoContainerBackgroundColor: isLightMode
              ? const Color.fromARGB(255, 199, 199, 199)
              : const Color.fromARGB(255, 1, 54, 98),
          infoTextStyle: TextStyle(
            color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white,
          ),
          contentPadding: const EdgeInsets.all(6),
          contentBorderRadius: const BorderRadius.all(Radius.circular(10)),
          infoTextAlign: TextAlign.center,
        ),
        dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
        contentTitle:
            "'+' to add\nswipe to delete\ntap to edit\n🔢 to calculate",
        child: const Icon(
          Icons.info_outline,
          color: Colors.grey,
        ),
      ),
    );
  }
}
