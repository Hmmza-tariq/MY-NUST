import 'package:flutter/material.dart';
import 'package:mynust/Components/webview.dart';
import 'package:provider/provider.dart';
import '../../Core/app_theme.dart';
import '../../Provider/theme_provider.dart';

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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Hey there, I'm Hamza Tariq (CE-43, CEME), the brain behind this app, Flutter fanatic, app aficionado, and your friendly neighborhood developer. I cooked up this app with a pinch of code, a sprinkle of passion, and a massive 15,000 lines of \"are we there yet?\" code. Hope it rocks your phone and brings a smile. Enjoy the adventure",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              'We take your privacy seriously. This app does not collect any personal data or information from its users. Any data you enter in the app, such as LMS / Qalam ID, Passwords or your GPA, is stored locally on your device and not shared with any third parties.',
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
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    'For more details visit:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const WebsiteView(
                                              initialUrl:
                                                  "https://sites.google.com/view/mynust-privacy-policy/home")),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.link_rounded),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const WebsiteView(
                                              initialUrl:
                                                  "https://sites.google.com/view/mynust-terms-and-conditions/home")),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.link_rounded),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Terms and Conditions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Request source code:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isLightMode
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                      Text(
                                        '(not going to approve it though)',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: isLightMode
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const WebsiteView(
                                              initialUrl:
                                                  "https://github.com/Hmmza-tariq/My-NUST-request-")),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.link_rounded),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Github',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
                            'Why ads?',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              ":)))",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
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
