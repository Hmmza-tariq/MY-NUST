import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mynust/Core/app_theme.dart';
import 'package:mynust/Core/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector;

class WaveView extends StatefulWidget {
  final String grade;

  const WaveView({Key? key, required this.grade}) : super(key: key);
  @override
  WaveViewState createState() => WaveViewState();
}

class WaveViewState extends State<WaveView> with TickerProviderStateMixin {
  AnimationController? animationController;
  AnimationController? waveAnimationController;
  Offset bottleOffset1 = const Offset(0, 0);
  List<Offset> animList1 = [];
  Offset bottleOffset2 = const Offset(60, 0);
  List<Offset> animList2 = [];
  double gradePoints = 0;
  int box = 1;
  Color gpaColor = Colors.white;

  @override
  void initState() {
    getData();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    waveAnimationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController?.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController?.forward();
      }
    });
    waveAnimationController!.addListener(() {
      animList1.clear();
      for (int i = -2 - bottleOffset1.dx.toInt(); i <= 60 + 2; i++) {
        animList1.add(
          Offset(
            i.toDouble() + bottleOffset1.dx.toInt(),
            (math.sin((waveAnimationController!.value * 360 - i) %
                            360 *
                            vector.degrees2Radians) *
                        4 +
                    (100 - (gradePoints * 25)))
                .clamp(-80, 80),
          ),
        );
      }
      animList2.clear();
      for (int i = -2 - bottleOffset2.dx.toInt(); i <= 60 + 2; i++) {
        animList2.add(
          Offset(
            i.toDouble() + bottleOffset2.dx.toInt(),
            (math.sin((waveAnimationController!.value * 360 - i) %
                            360 *
                            vector.degrees2Radians) *
                        4 +
                    (100 - (gradePoints * 25)) * 1)
                .clamp(-80, 80),
          ),
        );
      }
    });
    waveAnimationController?.repeat();
    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    waveAnimationController?.dispose();
    super.dispose();
  }

  void getData() {
    setState(() {
      switch (widget.grade) {
        case 'A':
          gradePoints = 4.0;
          box = 7;
          break;
        case 'B+':
          gradePoints = 3.5;
          box = 6;
          break;
        case 'B':
          gradePoints = 3.0;
          box = 5;
          break;
        case 'C+':
          gradePoints = 2.5;
          box = 4;
          break;
        case 'C':
          gradePoints = 2.0;
          box = 3;
          break;
        case 'D+':
          gradePoints = 1.5;
          box = 2;
          break;
        case 'D':
          gradePoints = 1.0;
          box = 1;
          break;
        default:
          gradePoints = 0.0;
          box = 1;
          break;
      }

      if (gradePoints <= 1) {
        gpaColor = Colors.red;
      } else if (gradePoints < 3) {
        gpaColor = Colors.orange;
      } else if (gradePoints < 4) {
        gpaColor = Colors.green;
      } else {
        gpaColor = AppTheme.ace;
      }
    });
  }

  @override
  void didUpdateWidget(WaveView oldWidget) {
    if (oldWidget.grade != widget.grade) {
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;

    return StatefulBuilder(builder: (context, setState) {
      return Container(
        height: 130,
        width: 30,
        padding: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.bottomCenter,
        child: AnimatedBuilder(
          animation: CurvedAnimation(
            parent: animationController!,
            curve: Curves.easeInOut,
          ),
          builder: (context, child) => ListView.builder(
            reverse: true,
            itemCount: box,
            itemBuilder: (context, index) {
              bool last = index == (box - 1);
              return Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: last ? 30 : 13,
                    width: 30,
                    decoration: BoxDecoration(
                      color: gpaColor,
                      borderRadius: BorderRadius.circular(last ? 6 : 4),
                      border: Border.all(
                          color: isLightMode ? Colors.white : AppTheme.grey,
                          width: 1),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: AppTheme.grey.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 12.0),
                      ],
                    ),
                  ),
                  if (last)
                    Text(
                      widget.grade,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}
