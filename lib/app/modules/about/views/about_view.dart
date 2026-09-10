import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/app_page_shell.dart';
import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) => AppPageShell(
        title: 'About My NUST',
        subtitle:
            'An independent student-built companion for common academic tasks.',
        child: Column(
          children: [
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AboutSection(
                    icon: Icons.verified_user_outlined,
                    title: 'Independent app',
                    body:
                        'My NUST is not affiliated with, authorized by, or endorsed by the National University of Sciences & Technology. NUST names, marks, and portal content belong to their respective owner.',
                  ),
                  const Divider(height: 32),
                  const _AboutSection(
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy',
                    body:
                        'Credentials and GPA planning data are stored locally on your device. The app does not send your LMS or Qalam password to our servers.',
                  ),
                  const Divider(height: 32),
                  _LinkRow(
                      label: 'Privacy policy',
                      url: controller.privacyPolicyLink),
                  _LinkRow(
                      label: 'Terms and conditions',
                      url: controller.termsAndConditionsLink),
                  _LinkRow(label: 'Source code', url: controller.githubLink),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share My NUST'),
                onPressed: () async {
                  final link = Platform.isAndroid
                      ? controller.playStoreLink
                      : controller.appStoreLink;
                  await SharePlus.instance.share(
                    ShareParams(text: 'My NUST student companion: $link'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _StoreButton(
                        label: 'Google Play', url: controller.playStoreLink)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StoreButton(
                        label: 'App Store', url: controller.appStoreLink)),
              ],
            ),
          ],
        ),
      );
}

class _AboutSection extends StatelessWidget {
  const _AboutSection(
      {required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: appSecondaryText(context), height: 1.5)),
              ],
            ),
          ),
        ],
      );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        minTileHeight: 48,
        title: Text(label),
        trailing: const Icon(Icons.open_in_new_rounded, size: 20),
        onTap: url.isEmpty ? null : () => launchUrl(Uri.parse(url)),
      );
}

class _StoreButton extends StatelessWidget {
  const _StoreButton({required this.label, required this.url});
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: url.isEmpty ? null : () => launchUrl(Uri.parse(url)),
        child: Text(label),
      );
}
