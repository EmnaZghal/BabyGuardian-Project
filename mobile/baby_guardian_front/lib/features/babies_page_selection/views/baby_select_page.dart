import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/service/auth_service.dart';
import '../models/baby_model.dart';
import '../services/baby_list_api.dart';

class BabySelectPage extends StatefulWidget {
  const BabySelectPage({super.key});

  @override
  State<BabySelectPage> createState() => _BabySelectPageState();
}

class _BabySelectPageState extends State<BabySelectPage> {
  final _auth = AuthService();

  bool _loading = true;
  String? _error;
  List<BabyModel> _babies = const [];

  @override
  void initState() {
    super.initState();
    _loadBabies();
  }

  Future<void> _loadBabies() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await BabyListApi.getMyBabies(auth: _auth);

      final list = data.map((e) {
        final m = Map<String, dynamic>.from(e);

        final gender = _asGender(m['gender'] ?? m['sex'] ?? 1);

        final firstName =
            (m['firstName'] ??
                    m['firstname'] ??
                    m['first_name'] ??
                    m['babyFirstName'] ??
                    m['name'] ??
                    m['fullName'] ??
                    'Baby')
                .toString();

        return BabyModel(
          id: _asInt(m['id'] ?? m['babyId'] ?? 0),
          name: firstName,
          gender: gender,
          ageLabel: (m['ageLabel'] ?? m['age'] ?? '').toString(),
        );
      }).toList();

      setState(() => _babies = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int _asGender(dynamic v) {
    final n = _asInt(v);
    return (n == 0) ? 0 : 1;
  }

  String _iconFromGender(int? gender) {
    if (gender == 0) return 'assets/images/girl_icon.png';
    return 'assets/images/boy_icon.png';
  }

  @override
  Widget build(BuildContext context) {
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
                  child: RefreshIndicator(
                    onRefresh: _loadBabies,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : (_error != null)
                        ? ListView(
                            children: [
                              _ErrorBox(message: _error!, onRetry: _loadBabies),
                            ],
                          )
                        : (_babies.isEmpty)
                        // ✅ EMPTY STATE
                        ? ListView(
                            children: [
                              const SizedBox(height: 30),
                              const _EmptyState(),
                              const SizedBox(height: 18),
                              _AddBabyCard(
                                onTap: () => context.go('/baby-create'),
                              ),
                              const SizedBox(height: 12),
                            ],
                          )
                        // ✅ NORMAL LIST
                        : ListView.separated(
                            itemCount: _babies.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              if (index < _babies.length) {
                                final b = _babies[index];
                                return _BabyCard(
                                  baby: _Baby(
                                    name: b.name,
                                    age: b.ageLabel,
                                    iconPath: _iconFromGender(b.gender),
                                  ),
                                  onTap: () => context.go(
                                    '/home?babyName=${Uri.encodeComponent(b.name)}',
                                  ),
                                );
                              }

                              return _AddBabyCard(
                                onTap: () => context.go('/baby-create'),
                              );
                            },
                          ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEFF6FF),
            ),
            child: const Icon(
              Icons.child_care,
              color: Color(0xFF60A5FA),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No babies yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Create your first baby profile to start monitoring.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Baby {
  final String name;
  final String age;
  final String iconPath;

  _Baby({required this.name, required this.age, required this.iconPath});
}

class _BabyCard extends StatelessWidget {
  final _Baby baby;
  final VoidCallback onTap;

  const _BabyCard({required this.baby, required this.onTap});

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
                  child: Image.asset(baby.iconPath, fit: BoxFit.cover),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      baby.age.isEmpty ? '—' : baby.age,
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

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7F1D1D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
