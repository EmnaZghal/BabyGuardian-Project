import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BabySelectPage extends StatelessWidget {
  const BabySelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final babies = [
      _Baby(
        name: 'Emma',
        age: '3 months',
        iconPath: 'assets/images/girl_icon.png',
      ),
      _Baby(
        name: 'Lucas',
        age: '6 months',
        iconPath: 'assets/images/boy_icon.png',
      ),
    ];

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a baby',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose the profile you want to monitor',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: babies.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index < babies.length) {
                        final b = babies[index];
                        return _BabyCard(
                          baby: b,
                          onTap: () => context.go('/home'),
                        );
                      }

                      // ✅ Add baby card navigation
                      return _AddBabyCard(
                        onTap: () {
                          // ✅ Navigate to create baby profile page
                          context.go('/baby-create');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Baby {
  final String name;
  final String age;
  final String iconPath;

  _Baby({
    required this.name,
    required this.age,
    required this.iconPath,
  });
}

class _BabyCard extends StatelessWidget {
  final _Baby baby;
  final VoidCallback onTap;

  const _BabyCard({
    required this.baby,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: ClipOval(
                  child: Image.asset(
                    baby.iconPath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baby.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      baby.age,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBabyCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddBabyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF60A5FA), Color(0xFF67E8F9)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.20),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 34),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a baby',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a new profile',
                        style: TextStyle(color: Color(0xCCFFFFFF)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
