import 'package:flutter/material.dart';

class PulseIcon extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const PulseIcon({super.key, required this.enabled, required this.child});

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (widget.enabled) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.enabled && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}
