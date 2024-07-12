import 'package:flutter/material.dart';
import 'package:mynust/Screens/Home/home_drawer_list.dart';
import 'package:mynust/Screens/Web%20view/webview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          PageTransition(
            duration: const Duration(milliseconds: 500),
            type: PageTransitionType.rightToLeft,
            alignment: Alignment.bottomCenter,
            child: const NavigationHomeScreen(),
            inheritTheme: true,
            ctx: context,
          ),
        );
        return false;
      },
      child: Container(
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
                                  fontFamily: AppTheme.fontName,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 100.0),
                            //   child: Divider(
                            //       thickness: 2,
                            //       height: 30,
                            //       color: themeProvider.primaryColor
                            //           .withOpacity(0.3)),
                            // ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Hey, I'm Hamza. Have a nice day! :)",
                                style: TextStyle(
                                    fontFamily: AppTheme.fontName,
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
                              color:
                                  themeProvider.primaryColor.withOpacity(0.8),
                              width: 3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                'Privacy Policy',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontName,
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
                                    fontFamily: AppTheme.fontName,
                                    fontSize: 16,
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              Text(
                                'By using this app, you agree to the following:',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontName,
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
                                    fontFamily: AppTheme.fontName,
                                    fontSize: 16,
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              Text(
                                '- We do not collect or store any personal information, including your name, email, or location.',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontName,
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
                                          fontFamily: AppTheme.fontName,
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
                                                    "https://sites.google.com/view/my-nust-privacy-policy/home")),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.link_rounded,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Privacy Policy',
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
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
                                                    "https://sites.google.com/view/my-nust-terms-and-conditions/home")),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.link_rounded,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Terms and Conditions',
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
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
                                              fontFamily: AppTheme.fontName,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        Text(
                                          '(not going to approve it though)',
                                          style: TextStyle(
                                              fontFamily: AppTheme.fontName,
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
                                    onPressed: () {
                                      launchUrl(
                                          mode: LaunchMode.externalApplication,
                                          Uri.parse(
                                              "https://github.com/Hmmza-tariq/My-NUST-request-"));
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Github',
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
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
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: themeProvider.primaryColor.withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //         color: themeProvider.primaryColor.withOpacity(0.8),
                    //         width: 3),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Column(
                    //       children: [
                    //         Text(
                    //           'Why ads?',
                    //           style: TextStyle(
                    //               fontFamily: AppTheme.fontName,
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold,
                    //               color: isLightMode
                    //                   ? Colors.black
                    //                   : Colors.white),
                    //         ),
                    //         Padding(
                    //           padding:
                    //               const EdgeInsets.symmetric(horizontal: 8.0),
                    //           child: Text(
                    //             ":)))",
                    //             style: TextStyle(
                    //                 fontFamily: AppTheme.fontName,
                    //                 fontSize: 16,
                    //                 color: isLightMode
                    //                     ? Colors.black
                    //                     : Colors.white),
                    //             textAlign: TextAlign.center,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
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
                        child: TextButton(
                          onPressed: () {
                            Share.share(
                              'Check out this cool NUST App available on PlayStore!🔥 \nDownload now: https://play.google.com/store/apps/details?id=com.hexagone.mynust&pcampaignid=web_share',
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Share this app',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.share_rounded,
                                  size: 20,
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
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
          )),
    );
  }
}
