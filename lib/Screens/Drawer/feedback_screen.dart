import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Core/app_theme.dart';
import '../../Core/email.dart';
import '../../Provider/theme_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
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
    bool success = _messageController.text.isNotEmpty
        ? await sendMail(
            message: _messageController.text,
            fromEmail: _mailController.text,
            screen: 'Feedback',
            fromName: 'No name',
          )
        : error = true;

    setState(() {
      isLoading = false;
      buttonText = error
          ? 'Enter Feedback'
          : success
              ? 'Success'
              : 'Failed';
      if (success) {
        _mailController.clear();
        _messageController.clear();
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        error = false;
        buttonText = 'Send';
      });
    });

    // ignore: use_build_context_synchronously
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
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
                  child: Image.asset('assets/images/feedback.png'),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Your FeedBack',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Give your best time for this moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.3,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        launchUrl(
                            mode: LaunchMode.externalApplication,
                            Uri.parse(
                                "https://play.google.com/store/apps/details?id=com.hexagone.mynust&pcampaignid=web_share"));
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Review on PlayStore',
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: 16,
                              // fontWeight: FontWeight.w400,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.rate_review_rounded,
                              size: 16, color: AppTheme.darkGrey),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? AppTheme.darkGrey : Colors.white,
                    ),
                  ),
                ),
                _buildComposer(isLightMode),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
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
                                  : Text(buttonText,
                                      style: isLightMode
                                          ? const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.notWhite,
                                            )
                                          : const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.darkText,
                                            )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(bool isLightMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 32, right: 32),
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
                          hintText: 'Enter your email (not mandatory)'),
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
                          hintText: 'Enter your feedback...'),
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
