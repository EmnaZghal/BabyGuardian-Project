import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/baby_create_request.dart';
import '../services/baby_api.dart';
import 'package:baby_guardian_front/features/auth/service/auth_service.dart';

class AddBabyFormPage extends StatefulWidget {
  const AddBabyFormPage({super.key});

  @override
  State<AddBabyFormPage> createState() => _AddBabyFormPageState();
}

class _AddBabyFormPageState extends State<AddBabyFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  int _gender = 0; // 0 girl, 1 boy
  DateTime? _birthDate;

  bool _loading = false;
  final _auth = AuthService();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  double _calcWeeksFromBirthDate(DateTime birth) {
    final days = DateTime.now().difference(birth).inDays;
    final weeks = days / 7.0;
    final safe = weeks.isNaN || weeks.isInfinite ? 0.0 : weeks;
    return safe < 0 ? 0.0 : double.parse(safe.toStringAsFixed(1));
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5, 1, 1);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) return;
    setState(() => _birthDate = picked);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      _toast('Please select a birth date');
      return;
    }

    final weight = double.tryParse(
      _weightCtrl.text.trim().replaceAll(',', '.'),
    );
    if (weight == null || weight <= 0) {
      _toast('Weight must be a valid number');
      return;
    }

    final birth = _birthDate!;
    final req = BabyCreateRequest(
      firstName: _firstNameCtrl.text.trim(),
      gender: _gender,
      birthDate: _fmtDate(birth),
      gestationalAgeWeeks: _calcWeeksFromBirthDate(birth),
      weightKg: double.parse(weight.toStringAsFixed(2)),
    );

    setState(() => _loading = true);

    try {
      final res = await BabyApi.createBaby(auth: _auth, body: req);

      if (!mounted) return;
      _toast('Baby created');

      // ✅ CHANGÉ: Utilise simple binding au lieu de BLE
      context.go(
        '/bind-device/${res.babyId}',
        extra: {'babyName': _firstNameCtrl.text.trim()},
      );
    } catch (e) {
      if (!mounted) return;
      _toast('Add baby failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEC4899), width: 1.2),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: Color(0x0F000000),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _genderChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFEC4899)
                  : const Color(0xFFE5E7EB),
              width: selected ? 1.2 : 1.0,
            ),
            color: selected ? const Color(0xFFFFF1F7) : const Color(0xFFF8FAFC),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xFFEC4899)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? const Color(0xFFEC4899)
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final birthText = _birthDate == null
        ? 'Select birth date'
        : _fmtDate(_birthDate!);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.go('/baby-create'),
        ),
        title: const Text(
          'Add new baby',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _card(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFBCFE8), Color(0xFFF9A8D4)],
                            ),
                          ),
                          child: const Icon(
                            Icons.child_friendly,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Baby profile',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Create the profile then link the device.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _firstNameCtrl,
                          decoration: _dec('Baby name', Icons.badge_outlined),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Baby name is required';
                            if (s.length < 2) return 'Too short';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Gender',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _genderChip(
                              label: 'Girl',
                              icon: Icons.female,
                              selected: _gender == 0,
                              onTap: () => setState(() => _gender = 0),
                            ),
                            const SizedBox(width: 12),
                            _genderChip(
                              label: 'Boy',
                              icon: Icons.male,
                              selected: _gender == 1,
                              onTap: () => setState(() => _gender = 1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        InkWell(
                          onTap: _pickBirthDate,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _dec(
                              'Birth date',
                              Icons.calendar_month,
                            ),
                            child: Text(
                              birthText,
                              style: TextStyle(
                                color: _birthDate == null
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF111827),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _dec(
                            'Weight (kg)',
                            Icons.monitor_weight_outlined,
                          ),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Weight is required';
                            final w = double.tryParse(s.replaceAll(',', '.'));
                            if (w == null) return 'Invalid number';
                            if (w <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create baby & Link device',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}