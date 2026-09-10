import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/app_page_shell.dart';
import 'package:nust/app/modules/widgets/app_dialog.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => AppPageShell(
          title: 'Settings',
          subtitle: 'Personalize access, appearance, and privacy.',
          child: Column(
            children: [
              AppSectionCard(
                child: Column(
                  children: [
                    SettingSwitchButton(
                      title: 'Dark Mode',
                      subTitle: 'Use a comfortable low-light appearance',
                      icon: Icons.dark_mode_outlined,
                      isSwitched: controller.themeController.isDarkMode,
                      onChanged: controller.themeController.toggleTheme,
                    ),
                    const Divider(height: 24),
                    SettingSwitchButton(
                      title: 'Biometric Authentication',
                      icon: Icons.fingerprint_rounded,
                      subTitle: controller
                              .authenticationController.supportState.value
                          ? 'Secure your account with biometric authentication'
                          : 'Biometric authentication is not supported on this device',
                      isSwitched:
                          controller.authenticationController.supportState.value
                              ? controller
                                  .authenticationController.isBiometricEnabled
                              : false.obs,
                      onChanged: controller
                              .authenticationController.supportState.value
                          ? controller.authenticationController.toggleBiometric
                          : null,
                    ),
                    const Divider(height: 24),
                    SettingSwitchButton(
                      title: 'Autofill ID / Password',
                      icon: Icons.password_rounded,
                      subTitle: 'Fill saved credentials in LMS and Qalam',
                      isSwitched:
                          controller.authenticationController.isAutofillEnabled,
                      onChanged: (bool value) {
                        if (value) {
                          addCredentials(controller);
                        } else {
                          controller.authenticationController.isAutofillEnabled
                              .value = false;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset settings'),
                  onPressed: () async {
                    final confirmed = await showAppConfirmationDialog(
                      context: context,
                      title: 'Reset settings?',
                      message:
                          'Theme, campus, saved calculator entries, and preferences will return to their defaults.',
                      confirmLabel: 'Reset',
                      icon: Icons.restart_alt_rounded,
                      destructive: true,
                    );
                    if (confirmed == true) controller.resetSettings();
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class SettingSwitchButton extends StatelessWidget {
  const SettingSwitchButton({
    super.key,
    required this.title,
    required this.subTitle,
    required this.isSwitched,
    required this.icon,
    this.onChanged,
  });

  final String title;
  final String subTitle;
  final RxBool isSwitched;
  final IconData icon;
  final void Function(bool)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: appSecondaryText(context),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Switch(
              value: isSwitched.value,
              onChanged: onChanged,
            ),
          ],
        ));
  }
}

void addCredentials(SettingsController controller) {
  final context = Get.context!;
  final idController = TextEditingController(
    text: controller.authenticationController.id.value,
  );
  final lmsPasswordController = TextEditingController(
    text: controller.authenticationController.lmsPassword.value,
  );
  final qalamPasswordController = TextEditingController(
    text: controller.authenticationController.qalamPassword.value,
  );
  final showLms = false.obs;
  final showQalam = false.obs;

  showAppSheet<void>(
    context: context,
    child: Obx(
      () => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal autofill',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Saved credentials stay encrypted on this device and are only inserted into the selected portal.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: idController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lmsPasswordController,
              obscureText: !showLms.value,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'LMS password',
                prefixIcon: const Icon(Icons.school_outlined),
                suffixIcon: IconButton(
                  tooltip: showLms.value ? 'Hide password' : 'Show password',
                  onPressed: () => showLms.toggle(),
                  icon: Icon(showLms.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qalamPasswordController,
              obscureText: !showQalam.value,
              decoration: InputDecoration(
                labelText: 'Qalam password',
                prefixIcon: const Icon(Icons.account_balance_outlined),
                suffixIcon: IconButton(
                  tooltip: showQalam.value ? 'Hide password' : 'Show password',
                  onPressed: () => showQalam.toggle(),
                  icon: Icon(showQalam.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      controller.authenticationController.setCredentials(
                        idController.text.trim(),
                        lmsPasswordController.text,
                        qalamPasswordController.text,
                      );
                      controller.authenticationController.toggleAutofill(true);
                      Get.back();
                    },
                    child: const Text('Save securely'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
