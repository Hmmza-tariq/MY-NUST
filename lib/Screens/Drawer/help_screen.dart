import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../Core/app_theme.dart';
import 'package:flutter/material.dart';

import '../../Core/email.dart';
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
    bool error = false;

    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

    bool success = (_messageController.text.isNotEmpty &&
            _mailController.text.isNotEmpty &&
            emailRegExp.hasMatch(_mailController.text))
        ? await sendMail(
            message: _messageController.text,
            fromEmail: _mailController.text,
            screen: 'Help',
            fromName: _nameController.text,
          )
        : error = true;

    setState(() {
      isLoading = false;
      buttonText = error
          ? 'Invalid Data'
          : success
              ? 'Sent'
              : 'Failed';
      if (success && !error) {
        _nameController.clear();
        _mailController.clear();
        _messageController.clear();
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        error = false;
        success = false;
        buttonText = 'Send';
      });
    });

    // ignore: use_build_context_synchronously
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Container(
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
