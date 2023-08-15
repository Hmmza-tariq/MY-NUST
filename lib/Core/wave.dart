import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

import 'app_Theme.dart';

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
          break;
        case 'B+':
          gradePoints = 3.5;
          break;
        case 'B':
          gradePoints = 3.0;
          break;
        case 'C+':
          gradePoints = 2.5;
          break;
        case 'C':
          gradePoints = 2.0;
          break;
        case 'D+':
          gradePoints = 1.5;
          break;
        case 'D':
          gradePoints = 1.0;
          break;
        default:
          gradePoints = 0.0;
          break;
      }

      if (gradePoints <= 1) {
        gpaColor = Colors.red;
      } else if (gradePoints > 1 && gradePoints < 3) {
        gpaColor = Colors.yellow;
      } else {
        gpaColor = Colors.green;
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
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: CurvedAnimation(
            parent: animationController!,
            curve: Curves.easeInOut,
          ),
          builder: (context, child) => Stack(
            children: <Widget>[
              ClipPath(
                clipper: WaveClipper(animationController!.value, animList1),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkerText.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(80.0),
                        bottomLeft: Radius.circular(80.0),
                        bottomRight: Radius.circular(80.0),
                        topRight: Radius.circular(80.0)),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkerText.withOpacity(0.2),
                        AppTheme.darkerText.withOpacity(0.5)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: WaveClipper(animationController!.value, animList2),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkerText,
                    gradient: LinearGradient(
                      colors: [
                        gpaColor.withOpacity(0.4),
                        gpaColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(80.0),
                        bottomLeft: Radius.circular(80.0),
                        bottomRight: Radius.circular(80.0),
                        topRight: Radius.circular(80.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.grade,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          letterSpacing: 0.0,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 6,
                bottom: 8,
                child: ScaleTransition(
                  alignment: Alignment.center,
                  scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animationController!,
                      curve: const Interval(0.0, 1.0,
                          curve: Curves.fastOutSlowIn))),
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 0,
                bottom: 16,
                child: ScaleTransition(
                  alignment: Alignment.center,
                  scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animationController!,
                      curve: const Interval(0.4, 1.0,
                          curve: Curves.fastOutSlowIn))),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 24,
                bottom: 32,
                child: ScaleTransition(
                  alignment: Alignment.center,
                  scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animationController!,
                      curve: const Interval(0.6, 0.8,
                          curve: Curves.fastOutSlowIn))),
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 20,
                bottom: 0,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 16 * (1.0 - animationController!.value), 0.0),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(
                          animationController!.status == AnimationStatus.reverse
                              ? 0.0
                              : 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset("assets/fitness_app/bottle.png"),
                  ),
                ],
              )
            ],
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
