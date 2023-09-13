import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Screens/Home/home_drawer_list.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../Components/toasts.dart';
import '../../Core/app_theme.dart';
import 'package:flutter/material.dart';
import '../../Provider/theme_provider.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  HelpScreenState createState() => HelpScreenState();
}

class HelpScreenState extends State<HelpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;
  bool sent = false;
  String buttonText = 'Send';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendButtonPressed(bool isLightMode) async {
    setState(() {
      isLoading = true;
      buttonText = '';
    });
    bool success = false;
    final emailPattern =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    bool isValidEmail = _mailController.text.isNotEmpty &&
        emailPattern.hasMatch(_mailController.text);
    bool isValidMessage = _messageController.text.isNotEmpty;
    bool error = !isValidEmail || !isValidMessage;
    if (error) {
      success = false;
      Toast().errorToast(context, 'Invalid Email or Message');
    } else {
      final Email email = Email(
        body:
            'Dear Team Hexag⬡ne,\n\nI am writing to request assistance with using My NUST.\n\n${_messageController.text}\n\nBest regards,\n${_nameController.text}',
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

    setState(() {
      isLoading = false;
      buttonText = success ? 'Success' : 'Failed';
      if (success) {
        _mailController.clear();
        _messageController.clear();
        _nameController.clear();
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        error = false;

        buttonText = 'Send';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
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
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 16,
                        right: 16),
                    child: Image.asset('assets/images/help.png'),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'How can we help you?',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(13),
                    child: Text(
                      'It looks like you are experiencing problems in our app. We are here to help so please get in touch with us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  ),
                  _buildComposer(isLightMode),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 30),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isLightMode ? Colors.blue : Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                          boxShadow: !isLightMode
                              ? null
                              : <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      offset: const Offset(4, 4),
                                      blurRadius: 8.0),
                                ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () => _handleSendButtonPressed(isLightMode),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: isLoading
                                    ? LoadingAnimationWidget.hexagonDots(
                                        size: 20,
                                        color: isLightMode
                                            ? AppTheme.white
                                            : AppTheme.grey,
                                      )
                                    : Text(
                                        buttonText,
                                        style: isLightMode
                                            ? const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.notWhite,
                                              )
                                            : const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.darkText,
                                              ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(bool isLightMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: !isLightMode
                    ? null
                    : <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.8),
                            offset: const Offset(4, 4),
                            blurRadius: 8),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  constraints:
                      const BoxConstraints(minHeight: 40, maxHeight: 160),
                  color: AppTheme.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 0, bottom: 0),
                    child: TextField(
                      controller: _nameController,
                      maxLines: null,
                      keyboardType: TextInputType.name,
                      onChanged: (String txt) {},
                      style: const TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 14,
                        color: AppTheme.darkGrey,
                      ),
                      cursorColor: Colors.blue,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your name (not mandatory)'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: !isLightMode
                    ? null
                    : <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.8),
                            offset: const Offset(4, 4),
                            blurRadius: 8),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  constraints:
                      const BoxConstraints(minHeight: 40, maxHeight: 160),
                  color: AppTheme.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 0, bottom: 0),
                    child: TextField(
                      controller: _mailController,
                      maxLines: null,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (String txt) {},
                      style: const TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 14,
                        color: AppTheme.darkGrey,
                      ),
                      cursorColor: Colors.blue,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your email'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: !isLightMode
                    ? null
                    : <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.8),
                            offset: const Offset(4, 4),
                            blurRadius: 8),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  constraints:
                      const BoxConstraints(minHeight: 80, maxHeight: 160),
                  color: AppTheme.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 0, bottom: 0),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      onChanged: (String txt) {},
                      style: const TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 16,
                        color: AppTheme.darkGrey,
                      ),
                      cursorColor: Colors.blue,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your query...'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
