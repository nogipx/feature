import 'package:flutter/material.dart';

class BouncingWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scale;
  final Curve curve;
  final bool enableBounce;

  const BouncingWidget({
    required this.child,
    Key? key,
    this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.scale = 0.95,
    this.curve = Curves.easeInOut,
    this.enableBounce = true,
  })  : assert(scale > 0 && scale <= 1.0),
        super(key: key);

  @override
  _BouncingWidgetState createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget>
    with SingleTickerProviderStateMixin {
  Animation<double>? _scale;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.enableBounce) {
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _scale = Tween<double>(begin: 1.0, end: widget.scale)
          .animate(CurvedAnimation(parent: _controller!, curve: widget.curve));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _controller?.forward();
      },
      onPointerUp: (PointerUpEvent event) {
        _controller?.reverse();
        if (widget.onTap == null) return;
        widget.onTap?.call();
      },
      child: widget.enableBounce
          ? ScaleTransition(
              scale: _scale ??
                  ConstantTween(1.0).animate(CurvedAnimation(
                      parent: _controller!, curve: widget.curve)),
              child: widget.child,
            )
          : widget.child,
    );
  }
}
