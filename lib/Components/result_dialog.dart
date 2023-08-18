import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import '../Core/app_Theme.dart';
import 'card_3_widget.dart';

class ResultDialog {
  GlobalKey previewContainer = GlobalKey();

  void showResult(
      {required context,
      required marksObtained,
      required marksTotal,
      required description1,
      required description2,
      required title1,
      required title2,
      required type,
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
                    'Expected $type',
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
                  marksObtained.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoPopupWidget(
                      contentOffset: const Offset(30, 0),
                      arrowTheme: InfoPopupArrowTheme(
                        arrowDirection: ArrowDirection.down,
                        color: isLightMode
                            ? const Color.fromARGB(255, 199, 199, 199)
                            : const Color.fromARGB(255, 1, 54, 98),
                      ),
                      contentTheme: InfoPopupContentTheme(
                        infoContainerBackgroundColor: isLightMode
                            ? const Color.fromARGB(255, 199, 199, 199)
                            : const Color.fromARGB(255, 1, 54, 98),
                        infoTextStyle: TextStyle(
                          color: isLightMode
                              ? AppTheme.nearlyBlack
                              : AppTheme.white,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 0),
                        contentBorderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        infoTextAlign: TextAlign.center,
                      ),
                      dismissTriggerBehavior:
                          PopupDismissTriggerBehavior.onTapArea,
                      customContent: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: isLightMode == true
                              ? AppTheme.white
                              : AppTheme.nearlyBlack,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RepaintBoundary(
                                key: previewContainer,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: isLightMode
                                        ? AppTheme.nearlyWhite
                                        : AppTheme.nearlyBlack,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            'My Expected Progress for this session:',
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: isLightMode
                                                  ? AppTheme.darkText
                                                  : AppTheme.white,
                                            )),
                                      ),
                                      Card3Widget(
                                        title1: title1,
                                        description1: description1,
                                        title2: title2,
                                        description2: description2,
                                        marksObtained: marksObtained,
                                        marksTotal: marksTotal,
                                        type: type,
                                        color: color,
                                      ),
                                    ],
                                  ),
                                )),
                            IconButton(
                                onPressed: () => captureScreenShot(type),
                                icon: Icon(
                                  Icons.share,
                                  color: isLightMode
                                      ? CupertinoColors.black
                                      : CupertinoColors.white,
                                ))
                          ],
                        ),
                      ),
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

  Future<bool> captureScreenShot(String type) async {
    await ShareFilesAndScreenshotWidgets().shareScreenshot(
        previewContainer, 1000, "Logo", "result.png", "image/png",
        text:
            "Hey! Check this out. I calculated my expected $type using 'My NUST' app.");
    return true;
  }
}

// class ScreenShotWidget extends StatelessWidget {
//   const ScreenShotWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return 
//   }
// }
