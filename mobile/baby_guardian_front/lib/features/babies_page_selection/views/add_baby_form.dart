import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/baby_create_request.dart';
import '../services/baby_api.dart';

// Ajuste si ton AuthService est ailleurs
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

  // yyyy-MM-dd
  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  /// Tu as demandé: gestationalAgeWeeks calculé depuis birthDate.
  /// (Techniquement c'est plutôt "ageWeeks", mais on respecte ton modèle.)
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

  String _buildErrorDetails(Object e) {
    // Compatible avec ton ancien ApiException (message seulement)
    // et la version “debug” (statusCode/endpoint/rawBody/debugString).
    try {
      final d = e as dynamic;

      // Si tu as debugString()
      try {
        final s = d.debugString();
        if (s is String) return s;
      } catch (_) {}

      final code = d.statusCode?.toString() ?? '-';
      final msg = d.message?.toString() ?? e.toString();
      final endpoint = d.endpoint?.toString() ?? '(unknown endpoint)';
      final rawBody = d.rawBody?.toString() ?? '(no raw body)';

      return 'HTTP $code\nENDPOINT: $endpoint\n\nMESSAGE:\n$msg\n\nRAW BODY:\n$rawBody';
    } catch (_) {
      return e.toString();
    }
  }

  void _showError(Object e) {
    final details = _buildErrorDetails(e);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        action: SnackBarAction(
          label: 'Details',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Add baby failed'),
                content: SingleChildScrollView(child: Text(details)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birth date')),
      );
      return;
    }

    final weight = double.tryParse(_weightCtrl.text.trim().replaceAll(',', '.'));
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight must be a valid number')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Baby added ✅ (id: ${res.babyId})')),
      );

      context.go('/select-baby');
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeks = (_birthDate == null) ? null : _calcWeeksFromBirthDate(_birthDate!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x14000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.go('/baby-create'),
        ),
        title: const Text(
          'Add new baby',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            fontSize: 18,
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
                  // ===== Header Card (logo + subtitle) =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 16,
                          color: Color(0x0F000000),
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
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
                              colors: [
                                Color(0xFFFBCFE8), // pink-200
                                Color(0xFFF9A8D4), // pink-300
                              ],
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
                                'Fill the details to create a new baby profile.',
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

                  // ===== Form Card =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Baby name
                        TextFormField(
                          controller: _firstNameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Baby name',
                            prefixIcon: const Icon(Icons.badge_outlined),
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
                          ),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Baby name is required';
                            if (s.length < 2) return 'Too short';
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // Gender radio
                        const Text(
                          'Gender',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<int>(
                                  value: 0,
                                  groupValue: _gender,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Girl',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  onChanged: (v) => setState(() => _gender = v ?? 0),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  value: 1,
                                  groupValue: _gender,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Boy',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  onChanged: (v) => setState(() => _gender = v ?? 1),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Birth date picker
                        InkWell(
                          onTap: _pickBirthDate,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Birth date',
                              prefixIcon: const Icon(Icons.calendar_month),
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
                            ),
                            child: Text(
                              _birthDate == null ? 'Select date' : _fmtDate(_birthDate!),
                              style: TextStyle(
                                color: _birthDate == null
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF111827),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Computed weeks
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDBEAFE)),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'gestationalAgeWeeks (auto)',
                                  style: TextStyle(
                                    color: Color(0xFF1E40AF),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                weeks == null ? '--' : weeks.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Weight
                        TextFormField(
                          controller: _weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: const Icon(Icons.monitor_weight_outlined),
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

                  // ===== Save button =====
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
                            'Save baby',
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
