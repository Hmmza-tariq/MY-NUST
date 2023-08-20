import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

import '../Core/app_Theme.dart';
import '../Provider/theme_provider.dart';

class SwipeCard extends StatefulWidget {
  const SwipeCard({super.key, required this.func1, required this.child});
  final Function func1;
  final Widget child;
  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return SwipeableTile.card(
      color: Colors.transparent,
      shadow: const BoxShadow(
        color: Colors.transparent,
        blurRadius: 0,
        offset: Offset(2, 2),
      ),
      horizontalPadding: 0,
      verticalPadding: 0,
      direction: SwipeDirection.horizontal,
      onSwiped: (direction) => widget.func1,
      backgroundBuilder: (context, direction, progress) {
        return AnimatedBuilder(
          animation: progress,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              color: progress.value > 0.4
                  ? const Color(0xFFed7474)
                  : isLightMode
                      ? AppTheme.white
                      : AppTheme.nearlyBlack,
            );
          },
        );
      },
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: widget.child,
      ),
    );
  }
}
