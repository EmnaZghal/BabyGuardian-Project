import 'dart:ui';

import 'package:baby_guardian_front/app/router/app_router.dart';
import 'package:baby_guardian_front/features/auth/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
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

  Future<void> _handleLogin() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final ok = await _auth.loginWithPassword(
        _emailCtrl.text.trim(),
        _pwdCtrl.text,
      );
      if (!mounted) return;

      if (ok) {
        AppRouter.isLoggedIn = true;
        context.go('/select-baby');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              Color(0xFF3B82F6), // blue-500
              Color(0xFF06B6D4), // cyan-500
              Color(0xFF7C3AED), // purple-600
            ],
          ),
        ),
        child: Stack(
          children: [
            // Blobs flous
            Positioned(
              top: -140,
              left: -140,
              child: _blurBlob(
                size: 320,
                color: Colors.white.withOpacity(0.10),
              ),
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
                        child: _glassCard(context),
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

  Widget _glassCard(BuildContext context) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo sans cadre
                _topLogo(),
                const SizedBox(height: 10),

                const Text(
                  'Login to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),

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
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (value.isEmpty) return 'Email required';
                    if (!re.hasMatch(value)) return 'Invalid email';
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
                  obscureText: _obscure,
                  validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
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

                // Bouton gradient
                _gradientButton(),

                const SizedBox(height: 14),

                // Lien signup (comme ton ancien écran Flutter)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: _loading ? null : () => context.go('/signup'),
                      child: const Text(
                        'Sign Up',
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

  Widget _gradientButton() {
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
            onTap: _loading ? null : _handleLogin,
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
                  : const Text(
                      'Sign In',
                      style: TextStyle(
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
