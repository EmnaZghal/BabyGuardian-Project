import 'package:flutter/material.dart';
import '../models/guide_step.dart';

class GuideStepView extends StatelessWidget {
  final GuideStep step;
  final int stepNumber;

  const GuideStepView({
    super.key,
    required this.step,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big image (show full image)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset(
                    step.imageAsset,
                    fit: BoxFit.contain, // show whole image
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Centered title: "1- Title"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$stepNumber- ${step.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
