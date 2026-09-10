import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_page_shell.dart';
import '../../widgets/custom_snackbar.dart';
import '../controllers/authentication_controller.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) => AppPageShell(
        title: 'Confirm it’s you',
        subtitle:
            'Authentication protects access to locally saved portal credentials.',
        scrollable: true,
        child: Column(
          children: [
            AppSectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 34),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: .14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.fingerprint_rounded,
                        size: 42, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('Biometric authentication',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                      'Use the biometric method configured on this device to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: appSecondaryText(context), height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Authenticate'),
                onPressed: () async {
                  final authenticated = await controller.authenticate();
                  if (authenticated) {
                    Get.offAllNamed(controller.page.value);
                  } else {
                    AppSnackbar.error(
                        title: 'Authentication failed',
                        message: 'Please try again.');
                  }
                },
              ),
            ),
          ],
        ),
      );
}
