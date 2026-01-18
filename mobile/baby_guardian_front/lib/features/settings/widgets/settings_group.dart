import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroup({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _withSeparators(children),
        ),
      ),
    );
  }

  List<Widget> _withSeparators(List<Widget> items) {
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF3F4F6), // gray-100
        ));
      }
    }
    return out;
  }
}
