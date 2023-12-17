import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class Toast {
  void errorToast(context, String description) {
    MotionToast.error(
      iconType: IconType.materialDesign,
      animationCurve: Curves.fastEaseInToSlowEaseOut,
      title: const Text(
        "Error",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      description: Text(
        description,
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
      ),
      width: MediaQuery.of(context).size.width / 1.2,
      height: 60,
      animationType: AnimationType.fromLeft,
    ).show(context);
  }

  void successToast(context, String description) {
    MotionToast.success(
      iconType: IconType.materialDesign,
      animationCurve: Curves.fastEaseInToSlowEaseOut,
      description: Text(
        description,
        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
      ),
      width: MediaQuery.of(context).size.width / 1.5,
      height: 60,
      animationType: AnimationType.fromLeft,
    ).show(context);
  }
}
