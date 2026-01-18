import 'dart:ui';

import 'package:baby_guardian_front/features/auth/service/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _pwdFocus = FocusNode();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _pwdFocus.dispose();
    super.dispose();
  }

  Future<void> _doSignUp() async {
    if (_loading) return;

    final state = _formKey.currentState;
    if (state == null || !state.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthApi.signup(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created, you can login now')),
      );
      context.go('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6), // blue
              Color(0xFF06B6D4), // cyan
              Color(0xFF7C3AED), // purple
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              left: -140,
              child: _blurBlob(size: 320, color: Colors.white.withOpacity(0.10)),
            ),
            Positioned(
              bottom: -160,
              right: -160,
              child: _blurBlob(
                size: 340,
                color: const Color(0xFFDDD6FE).withOpacity(0.18),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: AbsorbPointer(
                      absorbing: _loading,
                      child: Opacity(
                        opacity: _loading ? 0.7 : 1,
                        child: _glassCard(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurBlob({required double size, required Color color}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _glassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 30,
                offset: Offset(0, 18),
                color: Color(0x33000000),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _topLogo(),
                const SizedBox(height: 10),

                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),

                // Full name
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Full Name',
                    style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.length < 3) return 'Enter your full name';
                    return null;
                  },
                  decoration: _inputDecoration(
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_pwdFocus),
                  validator: (v) {
                    final email = (v ?? '').trim();
                    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (email.isEmpty) return 'Email required';
                    if (!re.hasMatch(email)) return 'Invalid email';
                    return null;
                  },
                  decoration: _inputDecoration(
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                // Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pwdCtrl,
                  focusNode: _pwdFocus,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _doSignUp(),
                  validator: (v) {
                    final s = v ?? '';
                    if (s.length < 6) return 'Min 6 characters';
                    return null;
                  },
                  decoration: _inputDecoration(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _gradientButton(
                  text: 'Sign Up',
                  onTap: _doSignUp,
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: _loading ? null : () => context.go('/login'),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topLogo() {
    return Image.asset(
      'assets/images/logo2.png',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }

  Widget _gradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x33000000),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _loading ? null : onTap,
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
