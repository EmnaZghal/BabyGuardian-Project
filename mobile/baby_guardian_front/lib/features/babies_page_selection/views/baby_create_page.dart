import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/guide_step.dart';
import '../widgets/guide_dots.dart';
import '../widgets/guide_step_view.dart';

class BabyCreatePage extends StatefulWidget {
  const BabyCreatePage({super.key});

  @override
  State<BabyCreatePage> createState() => _BabyCreatePageState();
}

class _BabyCreatePageState extends State<BabyCreatePage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final steps = const <GuideStep>[
    GuideStep(
      title: 'Create your baby profile',
      subtitle: '',
      imageAsset: 'assets/images/step1_create_baby.png',
      bullets: [],
    ),
    GuideStep(
      title: 'Pair your wristband',
      subtitle: '',
      imageAsset: 'assets/images/step2_pair_device.png',
      bullets: [],
    ),
    GuideStep(
      title: 'Connect Wi-Fi via BLE',
      subtitle: '',
      imageAsset: 'assets/images/step3_ble_wifi.png',
      bullets: [],
    ),
    GuideStep(
      title: 'Start monitoring',
      subtitle: '',
      imageAsset: 'assets/images/step4_monitor.png',
      bullets: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex >= steps.length - 1) {
      context.go('/add-baby');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _goPrevStep() {
    if (_currentIndex <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _backToSelectBaby() => context.go('/select-baby');

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == steps.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _backToSelectBaby,
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFF111827),
                      splashRadius: 22,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Getting started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/add-baby'),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Slides (no scroll)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: steps.length,
                    onPageChanged: (v) => setState(() => _currentIndex = v),
                    itemBuilder: (_, idx) {
                      return GuideStepView(
                        step: steps[idx],
                        stepNumber: idx + 1,
                      );
                    },
                  ),
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    GuideDots(count: steps.length, index: _currentIndex),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _currentIndex == 0 ? null : _goPrevStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF111827),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _goNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEC4899),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isLast ? 'Finish' : 'Next',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}