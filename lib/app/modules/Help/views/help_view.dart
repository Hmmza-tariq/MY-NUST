import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_page_shell.dart';
import '../controllers/help_controller.dart';

// Add or revise FAQ entries here. The UI supports any number of expandable
// items without changing the page layout.
const _faqItems = <({String question, String answer})>[
  (
    question: 'LMS or Qalam shows a blank page. What should I do?',
    answer:
        'Update My NUST from the store, confirm that your internet connection is working, then close and reopen the portal. If it still fails, use the official portal in your browser temporarily and send us the portal name and a screenshot.',
  ),
  (
    question: 'Why does a portal occasionally show 404 or load slowly?',
    answer:
        'NUST can change or temporarily disable portal routes. My NUST follows the current official login route, but server maintenance can still cause a slow page or 404. Refresh once, then try the official website if the problem continues.',
  ),
  (
    question: 'Where is my downloaded fee or mess challan?',
    answer:
        'Tap the print or download action in Qalam. My NUST will save supported documents through the phone download service. For a generated page that cannot be downloaded directly, the app opens the browser so you can print or save it there.',
  ),
  (
    question: 'How do I use the GPA planner?',
    answer:
        'Add completed semesters under CGPA, then add planned courses under SGPA. Use the plus and minus controls to change credits and grades. The projection card updates immediately to show the expected CGPA impact.',
  ),
  (
    question: 'What does Absolute score calculate?',
    answer:
        'Absolute score estimates your weighted course score from assessments completed so far. Enter each assessment weight, total marks, and your marks. Use Both only when lecture and lab have separate weightage in the course outline.',
  ),
  (
    question: 'Is My NUST an official university app?',
    answer:
        'No. My NUST is an independent student utility and is not affiliated with, authorized by, or endorsed by NUST. Official portal content remains owned and operated by NUST.',
  ),
];

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return AppPageShell(
      title: 'Help & feedback',
      subtitle:
          'Report a problem or suggest an improvement. Your email app will open with the details ready to send.',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const _FaqSection(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact support',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            AppSectionCard(
              child: Column(
                children: [
                  _HelpField(
                    controller: controller.nameController,
                    label: 'Name (optional)',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _HelpField(
                    controller: controller.mailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Email is required'
                        : !GetUtils.isEmail(value)
                            ? 'Enter a valid email'
                            : null,
                  ),
                  const SizedBox(height: 14),
                  _HelpField(
                    controller: controller.messageController,
                    label: 'How can we help?',
                    icon: Icons.chat_bubble_outline_rounded,
                    maxLines: 5,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Message is required'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Obx(() {
              final sending = controller.state.value == 'sending';
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: sending
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            controller.sendEmail();
                          }
                        },
                  icon: sending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(sending ? 'Opening email…' : 'Send feedback'),
                ),
              );
            }),
            const SizedBox(height: 14),
            Text(
              'My NUST is an independent student utility and is not an official NUST app.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: appSecondaryText(context),
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently asked questions',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Quick answers to common questions about My NUST.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appSecondaryText(context),
                ),
          ),
          const SizedBox(height: 12),
          AppSectionCard(
            padding: EdgeInsets.zero,
            child: _faqItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'FAQ answers will be added here soon.',
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      for (var index = 0;
                          index < _faqItems.length;
                          index++) ...[
                        ExpansionTile(
                          title: Text(_faqItems[index].question),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _faqItems[index].answer,
                              style: TextStyle(
                                color: appSecondaryText(context),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        if (index != _faqItems.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
          ),
        ],
      );
}

class _HelpField extends StatelessWidget {
  const _HelpField(
      {required this.controller,
      required this.label,
      required this.icon,
      this.keyboardType,
      this.validator,
      this.maxLines = 1});

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;
    final field = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlignVertical:
          isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
      textInputAction:
          isMultiline ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: isMultiline,
        contentPadding:
            isMultiline ? const EdgeInsets.fromLTRB(40, 26, 16, 16) : null,
        prefixIcon: isMultiline ? null : Icon(icon),
      ),
    );

    if (!isMultiline) return field;
    return Stack(
      children: [
        field,
        Positioned(
          left: 12,
          top: 24,
          child: IgnorePointer(
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
