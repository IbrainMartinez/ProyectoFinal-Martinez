// pub: https://pub.dev/packages/delayed_display
// license: https://raw.githubusercontent.com/ThomasEcalle/delayed_display/master/LICENSE
// remade (not original)

import 'dart:async';

import 'package:flutter/material.dart';

class DelayedDisplay extends StatefulWidget {
  /// DelayedDisplay constructor
  const DelayedDisplay({
    required this.child,
    this.delay = Duration.zero,
    this.fadingDuration = const Duration(milliseconds: 800),
    this.slidingCurve = Curves.decelerate,
    this.slidingBeginOffset = const Offset(0, 0.35),
    this.fadeIn = true,
  });

  /// Child that will be displayed with the animation and delay
  final Widget child;

  /// Delay before displaying the widget and the animations
  final Duration delay;

  /// Duration of the fading animation
  final Duration fadingDuration;

  /// Curve of the sliding animation
  final Curve slidingCurve;

  /// Offset of the widget at the beginning of the sliding animation
  final Offset slidingBeginOffset;

  /// If true, make the child appear, disappear otherwise. Default to true.
  final bool fadeIn;

  @override
  _DelayedDisplayState createState() => _DelayedDisplayState();
}

class _DelayedDisplayState extends State<DelayedDisplay>
    with TickerProviderStateMixin {

  late AnimationController _opacityController;


  late Animation<Offset> _slideAnimationOffset;

  Timer? _timer;


  Duration get delay => widget.delay;


  Duration get opacityTransitionDuration => widget.fadingDuration;


  Curve get slidingCurve => widget.slidingCurve;


  Offset get beginOffset => widget.slidingBeginOffset;


  bool get fadeIn => widget.fadeIn;


  @override
  void initState() {
    super.initState();

    _opacityController = AnimationController(
      vsync: this,
      duration: opacityTransitionDuration,
    );

    final curvedAnimation = CurvedAnimation(
      curve: slidingCurve,
      parent: _opacityController,
    );

    _slideAnimationOffset = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(curvedAnimation);

    _runFadeAnimation();
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(DelayedDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fadeIn == fadeIn) {
      return;
    }
    _runFadeAnimation();
  }

  void _runFadeAnimation() {
    _timer = Timer(delay, () {
      fadeIn ? _opacityController.forward() : _opacityController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityController,
      child: SlideTransition(
        position: _slideAnimationOffset,
        child: widget.child,
      ),
    );
  }
}
