import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';

class HelpController extends GetxController {
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final messageController = TextEditingController();
  void sendEmail() async {
    bool success = false;
    final emailPattern =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    bool isValidEmail = mailController.text.isNotEmpty &&
        emailPattern.hasMatch(mailController.text);
    bool isValidMessage = messageController.text.isNotEmpty;
    bool error = !isValidEmail || !isValidMessage;
    if (error) {
      success = false;
      // Toast().errorToast(context, 'Invalid Email or Message');
    } else {
      final Email email = Email(
        body:
            'Dear Team Hexag⬡ne,\n\nI am writing to request assistance with using My NUST.\n\n${messageController.text}\n\nBest regards,\n${nameController.text}',
        subject: 'Help needed using My NUST',
        recipients: ['hexagone.playstore@gmail.com'],
        isHTML: false,
      );

      try {
        await FlutterEmailSender.send(email);
        success = true;
      } catch (error) {
        success = false;
      }
    }

    // setState(() {
    //   isLoading = false;
    //   buttonText = success ? 'Success' : 'Failed';
    if (success) {
      mailController.clear();
      messageController.clear();
      nameController.clear();
    }
    // });

    // Future.delayed(const Duration(seconds: 3), () {
    //   setState(() {
    //     error = false;

    //     buttonText = 'Send';
    //   });
    // });
  }
}
