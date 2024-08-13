import 'color_manager.dart';
import 'package:flutter/material.dart';

final otpInputDecoration = InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 15),
    border: customOutlineInputBorder(
        borderRadius: 15, borderColor: ColorManager.textColor),
    focusedBorder: customOutlineInputBorder(
        borderRadius: 15, borderColor: ColorManager.textColor),
    enabledBorder: customOutlineInputBorder(
        borderRadius: 15, borderColor: ColorManager.textColor));

final searchFieldInputDecoration = InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 15),
    hintText: "Search",
    border: customOutlineInputBorder(
        borderColor: ColorManager.primary, borderRadius: 80, borderWidth: 2),
    focusedBorder: customOutlineInputBorder(
        borderColor: ColorManager.secondary, borderRadius: 80, borderWidth: 2),
    // hintText: "Search",
    prefixIcon: Container(
      margin: const EdgeInsets.only(left: 20),
      child: const Icon(Icons.search),
    ),
    prefixIconConstraints: const BoxConstraints(maxHeight: 45, maxWidth: 45),
    prefixText: "  ");

OutlineInputBorder customOutlineInputBorder(
    {Color? borderColor, double? borderRadius, double borderWidth = 1}) {
  return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius!),
      borderSide: BorderSide(color: borderColor!, width: borderWidth));
}
