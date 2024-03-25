import 'package:elite_wallet/themes/extensions/elite_scrollbar_theme.dart';
import 'package:flutter/material.dart';

class EliteScrollbar extends StatelessWidget {
  EliteScrollbar({
    required this.backgroundHeight,
    required this.thumbHeight,
    required this.fromTop,
    this.rightOffset = 6,
    this.backgroundColor,
    this.thumbColor,
    this.width = 6,
  });

  final double backgroundHeight;
  final double thumbHeight;
  final double fromTop;
  final double width;
  final double rightOffset;
  final Color? backgroundColor;
  final Color? thumbColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: rightOffset,
        child: Container(
          height: backgroundHeight,
          width: width,
          decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).extension<EliteScrollbarTheme>()!.trackColor,
              borderRadius: BorderRadius.all(Radius.circular(3))),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: Duration(milliseconds: 0),
                top: fromTop,
                child: Container(
                  height: thumbHeight,
                  width: width,
                  decoration: BoxDecoration(
                      color: thumbColor ??
                          Theme.of(context).extension<EliteScrollbarTheme>()!.thumbColor,
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                ),
              )
            ],
          ),
        ));
  }
}
