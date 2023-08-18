import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:mynust/Components/action_button.dart';
import '../../Components/result_dialog.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';
import 'package:provider/provider.dart';

class CalcAggregateScreen extends StatefulWidget {
  static String id = "CalcAggregate_Screen";

  const CalcAggregateScreen({super.key});

  @override
  CalcAggregateScreenState createState() => CalcAggregateScreenState();
}

class CalcAggregateScreenState extends State<CalcAggregateScreen> {
  TextEditingController sscPercentageController = TextEditingController(),
      hsscPercentageController = TextEditingController(),
      netPercentageController = TextEditingController(),
      sscController = TextEditingController(),
      hsscController = TextEditingController(),
      netController = TextEditingController();
  double ssc = 0.0,
      hssc = 0.0,
      net = 0.0,
      sscPercentage = 10,
      hsscPercentage = 15,
      netPercentage = 75;
  bool _marks = false, _isEditing = false;
  @override
  void initState() {
    sscPercentageController.text = '10';
    hsscPercentageController.text = '15';
    netPercentageController.text = '75';
    super.initState();
  }

  double calculateAggregate() {
    return _marks
        ? ((ssc / 1100) * sscPercentage +
            (hssc / 1100) * hsscPercentage +
            (net / 200) * netPercentage)
        : ((ssc / 100 * sscPercentage) +
            (hssc / 100 * hsscPercentage) +
            ((net / 200) * netPercentage));
  }

  void resultDialog(bool isLightMode) {
    Color aggregateColor;
    double aggregate = calculateAggregate();
    bool error1 = (ssc == 0 || hssc == 0 || net == 0);
    bool error2 = ((sscPercentage + hsscPercentage + netPercentage) != 100);
    bool error3 = (aggregate > 100);

    if (aggregate < 50) {
      aggregateColor = Colors.red;
    } else if (aggregate >= 50 && aggregate < 70) {
      aggregateColor = Colors.orange;
    } else if (aggregate < 90) {
      aggregateColor = Colors.green;
    } else {
      aggregateColor = AppTheme.ace;
    }

    (error1 || error2 || error3)
        ? ResultDialog.showError(
            description: error1
                ? 'Incomplete Data'
                : error2
                    ? 'Total percentage is \nnot equal to 100'
                    : 'Incorrect Data',
            isLightMode: isLightMode,
            context: context)
        : ResultDialog().showResult(
            context: context,
            isLightMode: isLightMode,
            color: aggregateColor,
            title1: 'NET',
            description1: ((net / 200) * netPercentage).toDouble(),
            title2: 'Previous',
            description2: _marks
                ? ((ssc / 1100) * sscPercentage +
                        (hssc / 1100) * hsscPercentage)
                    .toDouble()
                : ((ssc / 100 * sscPercentage) + (hssc / 100 * hsscPercentage))
                    .toDouble(),
            marksObtained: aggregate.toDouble(),
            marksTotal: (100).toDouble(),
            type: 'Aggregate');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor:
          isLightMode == true ? AppTheme.white : AppTheme.nearlyBlack,
      appBar: AppBar(
        shadowColor: Colors.grey.withOpacity(0.6),
        elevation: 1,
        backgroundColor:
            isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        leading: null,
        iconTheme:
            IconThemeData(color: isLightMode ? Colors.black : Colors.white),
        title: Text(
          'Aggregate Calculator',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InfoPopupWidget(
              contentOffset: const Offset(0, 0),
              arrowTheme: InfoPopupArrowTheme(
                arrowDirection: ArrowDirection.up,
                color: isLightMode
                    ? const Color.fromARGB(255, 199, 199, 199)
                    : const Color.fromARGB(255, 1, 54, 98),
              ),
              contentTheme: InfoPopupContentTheme(
                infoContainerBackgroundColor: isLightMode
                    ? const Color.fromARGB(255, 199, 199, 199)
                    : const Color.fromARGB(255, 1, 54, 98),
                infoTextStyle: TextStyle(
                  color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white,
                ),
                contentPadding: const EdgeInsets.all(6),
                contentBorderRadius:
                    const BorderRadius.all(Radius.circular(10)),
                infoTextAlign: TextAlign.center,
              ),
              dismissTriggerBehavior: PopupDismissTriggerBehavior.onTapArea,
              customContent: Container(
                decoration: BoxDecoration(
                  color: isLightMode == true
                      ? AppTheme.white
                      : AppTheme.nearlyBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: themeProvider.primaryColor.withOpacity(0.8),
                      width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          label: const Text('SSC weightage:'),
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white),
                        ),
                        controller: sscPercentageController,
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            sscPercentage = double.parse(value);
                          });
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          label: const Text(
                            'HSSC weightage:',
                          ),
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white),
                        ),
                        controller: hsscPercentageController,
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            hsscPercentage = double.parse(value);
                          });
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          label: const Text(
                            'NET Score weightage:',
                          ),
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white),
                        ),
                        controller: netPercentageController,
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            netPercentage = double.parse(value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isLightMode
                        ? AppTheme.notWhite
                        : themeProvider.primaryColor,
                    width: 3),
                boxShadow: !isLightMode
                    ? null
                    : <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            offset: const Offset(0, 8),
                            blurRadius: 8.0),
                      ],
              ),
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.all(0),
                activeTrackColor: Colors.grey,
                inactiveTrackColor: Colors.grey,
                inactiveThumbColor: Colors.white,
                title: Text(
                  _marks ? 'Add Marks' : 'Add Percentages',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 16,
                      color: _isEditing
                          ? Colors.grey
                          : isLightMode
                              ? Colors.black
                              : Colors.white),
                ),
                value: _marks,
                onChanged: (bool value) {
                  _isEditing
                      ? setState(() {
                          if (sscController.text.isEmpty &&
                              hsscController.text.isEmpty &&
                              netController.text.isEmpty) {
                            _isEditing = !_isEditing;
                          }
                        })
                      : setState(() {
                          _marks = !_marks;
                        });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isLightMode
                          ? AppTheme.notWhite
                          : themeProvider.primaryColor,
                      width: 3),
                  boxShadow: !isLightMode
                      ? null
                      : <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              offset: const Offset(0, 8),
                              blurRadius: 8.0),
                        ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: sscController,
                        decoration: InputDecoration(
                          label: Text(_marks
                              ? 'Enter Marks obtained in SSC (out of 1100):'
                              : 'Enter percentage obtained in SSC or equivalent:'),
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white,
                              fontSize: 12),
                        ),
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _isEditing = true;
                            ssc = double.parse(value);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: hsscController,
                        decoration: InputDecoration(
                          label: Text(
                            _marks
                                ? 'Enter Marks obtained in HSSC (out of 1100):'
                                : 'Enter percentage obtained in HSSC or equivalent:',
                          ),
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white,
                              fontSize: 12),
                        ),
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _isEditing = true;
                            hssc = double.parse(value);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: netController,
                        decoration: InputDecoration(
                          label: const Text(
                            'Enter Marks obtained in NET (out of 200):',
                          ),
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white,
                              fontSize: 12),
                        ),
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _isEditing = true;
                            net = double.parse(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ActionButton(
          func: () => resultDialog(isLightMode),
          icon: Icons.calculate,
          color: Colors.pink),
    );
  }
}
