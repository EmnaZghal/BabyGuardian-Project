import 'package:flutter/material.dart';

class BarSparkline extends StatelessWidget {
  final List<double> values;
  final double min;
  final double max;
  final LinearGradient gradient;

  const BarSparkline({
    super.key,
    required this.values,
    required this.min,
    required this.max,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 70.0;

    return SizedBox(
      height: maxBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: _targetHeight(values[i], min, max, maxBarHeight),
                  ),
                  duration: Duration(milliseconds: 350 + i * 55),
                  curve: Curves.easeOutCubic,
                  builder: (context, h, _) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: h,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              color: Color(0x14000000),
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _targetHeight(double v, double min, double max, double maxBarHeight) {
    if (max <= min) return 0.0;
    final t = ((v - min) / (max - min)).clamp(0.0, 1.0);
    return (t * maxBarHeight).toDouble();
  }
}
