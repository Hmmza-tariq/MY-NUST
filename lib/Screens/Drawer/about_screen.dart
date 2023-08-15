import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';

class AboutScreen extends StatefulWidget {
  static String id = "About_Screen";
  const AboutScreen({super.key});
  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;

    return Container(
        color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor:
                isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
            body: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Image.asset('assets/images/aboutUs.png'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: themeProvider.primaryColor.withOpacity(0.8),
                          width: 3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Author Description',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 100.0),
                            child: Divider(
                                thickness: 2,
                                height: 30,
                                color: themeProvider.primaryColor
                                    .withOpacity(0.3)),
                          ),
                          Text(
                            'Hello! I am Hamza Tariq (CE-43, CEME), the developer of this app. I am passionate about Flutter and creating useful applications. I hope you find this app helpful and enjoy using it!',
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: themeProvider.primaryColor.withOpacity(0.8),
                            width: 3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'We take your privacy seriously. This app does not collect any personal data or information from its users. Any data you enter in the app, such as LMS / Qalam ID, Passwords and your GPA, is stored locally on your device and not shared with any third parties.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            Text(
                              'By using this app, you agree to the following:',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '- All data you enter in the app is stored locally on your device and is not shared with any external servers.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            Text(
                              '- We do not collect or store any personal information, including your name, email, or location.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            Text(
                              '- This app may use cookies or similar technologies to enhance user experience, but these are used for app functionality only and not for tracking or collecting data.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ));
  }
}
