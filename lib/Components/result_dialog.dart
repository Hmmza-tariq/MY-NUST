import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import '../Core/app_Theme.dart';
import 'card_3_widget.dart';

class ResultDialog {
  GlobalKey previewContainer = GlobalKey();

  void showResult(
      {required context,
      required String title,
      required String description,
      required bool isLightMode,
      required Color color}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLightMode
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                FittedBox(
                  child: SizedBox(
                    height: 100,
                    width: 400,
                    child: Visibility(
                      visible: true,
                      child: RepaintBoundary(
                          key: previewContainer,
                          child: const Card3Widget(
                            description: '',
                            marksObtained: 4,
                            marksTotal: 4,
                            name: 'GPA',
                          )),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        captureScreenShot();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 14,
                          color: isLightMode
                              ? CupertinoColors.black
                              : CupertinoColors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 14,
                          color: isLightMode
                              ? CupertinoColors.black
                              : CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showError(
      {required context,
      required String description,
      required bool isLightMode}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'ERROR!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLightMode
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 14,
                          color: isLightMode
                              ? CupertinoColors.black
                              : CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void captureScreenShot() {
    ShareFilesAndScreenshotWidgets().shareScreenshot(
        previewContainer, 800, "Logo", "result.png", "image/png",
        text: "Hey! Check this out");
  }
}

// class ScreenShotWidget extends StatelessWidget {
//   const ScreenShotWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return 
//   }
// }
