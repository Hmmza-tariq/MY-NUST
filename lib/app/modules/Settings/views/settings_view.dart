import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/app_page_shell.dart';
import 'package:nust/app/services/academic_sync_service.dart';
import 'package:nust/app/modules/widgets/app_dialog.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/modules/widgets/portal_sync_setup_dialog.dart';
import 'package:nust/app/modules/widgets/portal_connection_tile.dart';
import 'delete_data_sheet.dart';
import 'package:nust/app/modules/widgets/custom_snackbar.dart';

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
              if (kDebugMode || const bool.fromEnvironment('DEMO_MODE'))
                SwitchListTile(
                  title: const Text('Demo mode'),
                  subtitle: const Text(
                      'Sample courses, marks and classes. Real data stays unchanged.'),
                  value: Get.find<AcademicSyncService>().demoMode.value,
                  onChanged: Get.find<AcademicSyncService>().setDemoMode,
                ),
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
                    PortalConnectionTile(
                      enabled: Get.find<AcademicSyncService>()
                          .automaticEnabled
                          .value,
                      syncing: Get.find<AcademicSyncService>().isSyncing.value,
                      hasCredentials: controller
                          .authenticationController.id.value.isNotEmpty,
                      needsAttention: Get.find<AcademicSyncService>()
                          .credentialsRejected
                          .value,
                      bannerHidden: Get.find<AcademicSyncService>()
                          .connectionBannerHidden
                          .value,
                      onManage: () => addCredentials(controller),
                      onPrivacy: () async {
                        if (await showPortalSyncSetup(context) == true &&
                            !Get.find<AcademicSyncService>()
                                .automaticEnabled
                                .value) {
                          addCredentials(controller, consentAccepted: true);
                        }
                      },
                      onShowBanner: () async {
                        await Get.find<DatabaseController>()
                            .setConnectionBannerHidden(false);
                        Get.find<AcademicSyncService>()
                            .connectionBannerHidden
                            .value = false;
                      },
                      onChanged: (enabled) async {
                        final auth = controller.authenticationController;
                        final sync = Get.find<AcademicSyncService>();
                        if (enabled) {
                          if (auth.id.value.trim().isEmpty ||
                              (auth.qalamPassword.value.isEmpty &&
                                  auth.lmsPassword.value.isEmpty)) {
                            addCredentials(controller);
                            return;
                          }
                          if (await showPortalSyncSetup(context) != true) {
                            return;
                          }
                        }
                        await sync.setAutomaticSync(enabled);
                        if (enabled) await sync.syncSavedPortals();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppSectionCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error),
                  title: const Text('Manage saved data'),
                  subtitle:
                      const Text('Choose what to delete, or reset everything'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final selected = await showAppSheet<Set<SavedDataCategory>>(
                      context: context,
                      child: const DeleteDataSheet(),
                    );
                    if (selected != null && selected.isNotEmpty) {
                      try {
                        await controller.deleteSelectedData(selected);
                      } catch (_) {
                        if (context.mounted) {
                          AppSnackbar.error(
                              message:
                                  'Could not remove all selected data. Please try again.');
                        }
                      }
                    }
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

Future<void> addCredentials(SettingsController controller,
    {bool consentAccepted = false}) async {
  final context = Get.context!;
  if (!consentAccepted &&
      !Get.find<AcademicSyncService>().automaticEnabled.value &&
      await showPortalSyncSetup(context) != true) {
    return;
  }
  if (!context.mounted) return;
  final idController = TextEditingController(
    text: controller.authenticationController.id.value,
  );
  final lmsPasswordController = TextEditingController(
    text: controller.authenticationController.lmsPassword.value,
  );
  final qalamPasswordController = TextEditingController(
    text: controller.authenticationController.qalamPassword.value,
  );
  final error = ''.obs;
  final saving = false.obs;
  final showLms = false.obs;
  final showQalam = false.obs;

  await showAppSheet<void>(
    context: context,
    child: Obx(
      () => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal connection',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Save your portal details on this device. Connecting enables autofill and automatic sync; you can turn both off in Settings.',
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
            if (error.value.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(error.value,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))),
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
                    onPressed: saving.value
                        ? null
                        : () async {
                            error.value = validatePortalCredentials(
                                    idController.text,
                                    lmsPasswordController.text,
                                    qalamPasswordController.text) ??
                                '';
                            if (error.value.isNotEmpty) return;
                            saving.value = true;
                            try {
                              final sync = Get.find<AcademicSyncService>();
                              await sync.saveConnection(
                                  idController.text.trim(),
                                  lmsPasswordController.text,
                                  qalamPasswordController.text);
                              await Get.find<DatabaseController>()
                                  .setAcademicSetupSeen();
                              sync.credentialsRejected.value = false;
                              Get.back();
                              sync.syncSavedPortals();
                            } catch (_) {
                              error.value =
                                  'Could not save credentials. Please try again.';
                              saving.value = false;
                            }
                          },
                    child: Text(saving.value ? 'Saving…' : 'Save & connect'),
                  ),
                ),
              ],
            ),
            TextButton.icon(
                icon: const Icon(Icons.link_off_outlined),
                label: const Text('Remove connection data'),
                onPressed: saving.value
                    ? null
                    : () async {
                        if (await showAppConfirmationDialog(
                                context: context,
                                title: 'Remove connection?',
                                message:
                                    'Saved credentials, portal cookies, and synced summaries will be removed. Planner entries and downloaded files are kept.',
                                confirmLabel: 'Remove',
                                destructive: true) ==
                            true) {
                          await Get.find<AcademicSyncService>().disconnect();
                          Get.back();
                        }
                      }),
          ],
        ),
      ),
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 400));
  idController.dispose();
  lmsPasswordController.dispose();
  qalamPasswordController.dispose();
}

String? validatePortalCredentials(
    String id, String lmsPassword, String qalamPassword) {
  if (id.trim().isEmpty) return 'Enter your student ID.';
  if (lmsPassword.isEmpty && qalamPassword.isEmpty) {
    return 'Add a Qalam or LMS password to connect.';
  }
  return null;
}
