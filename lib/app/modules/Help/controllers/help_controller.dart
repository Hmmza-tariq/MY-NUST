import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/theme_controller.dart';

class HelpController extends GetxController {
  final ThemeController themeController = Get.find();
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final messageController = TextEditingController();
  var state = "idle".obs;

  // @override
  // void onClose() {
  //   formKey = GlobalKey<FormState>();
  //   super.onClose();
  // }

  void sendEmail() async {
    state.value = "sending";
    final emailPattern =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    bool isValidEmail = mailController.text.isNotEmpty &&
        emailPattern.hasMatch(mailController.text);
    bool isValidMessage = messageController.text.isNotEmpty;
    bool error = !isValidEmail || !isValidMessage;
    if (error) {
      state.value = "error";
      return;
    } else {
      final Email email = Email(
        body:
            'Dear Team Hexag⬡ne,\n\nI am writing to request assistance with using My NUST.\n\n${messageController.text}\n\nBest regards,\n${nameController.text}',
        subject: 'Help needed using My NUST',
        recipients: ['HexagonePk@gmail.com'],
        isHTML: false,
      );

      try {
        await FlutterEmailSender.send(email);
        state.value = "success";
      } catch (error) {
        state.value = "error";
        debugPrint("Error sending email: $error");
      }
    }

    if (state.value == "success") {
      Get.snackbar(
        "Success",
        "Your message has been sent successfully",
        backgroundColor: themeController.theme.primaryColor.withOpacity(0.4),
        colorText: themeController.theme.appBarTheme.titleTextStyle!.color!
            .withOpacity(0.8),
      );
      mailController.clear();
      messageController.clear();
      nameController.clear();
    }

    Future.delayed(const Duration(seconds: 3), () {
      state.value = "idle";
    });
  }
}
