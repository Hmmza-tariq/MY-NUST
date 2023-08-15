import 'package:flutter/material.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';
import 'package:provider/provider.dart';

class CalcAggregateScreen extends StatefulWidget {
  static String id = "CalcAggregate_Screen";

  const CalcAggregateScreen({super.key});

  @override
  CalcAggregateScreenState createState() => CalcAggregateScreenState();
}

class CalcAggregateScreenState extends State<CalcAggregateScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    animationController?.forward();
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
      ),
    );
  }
}
