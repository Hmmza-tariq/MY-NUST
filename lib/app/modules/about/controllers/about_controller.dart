import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/theme_controller.dart';

class AboutController extends GetxController {
  final ThemeController themeController = Get.find();
  String playStoreLink = dotenv.env['PLAY_STORE_LINK'] ?? '';
  String appStoreLink = dotenv.env['APP_STORE_LINK'] ?? '';
  String privacyPolicyLink = dotenv.env['PRIVACY_POLICY_LINK'] ?? '';
  String termsAndConditionsLink = dotenv.env['TERMS_AND_CONDITIONS_LINK'] ?? '';
  String githubLink = dotenv.env['GITHUB_LINK'] ?? '';
}
