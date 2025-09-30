import 'package:baby_guardian_front/shared/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_guardian_front/app/router/app_router.dart';
import 'package:baby_guardian_front/features/auth/service/auth_service.dart';

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

  InputDecoration _roundedInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)), // gris clair
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.oceanBlue, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
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
        context.go('/home');
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
    final card = Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: -4,
            offset: Offset(0, 6),
            color: Color(0x1A000000),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email
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
              decoration: _roundedInputDecoration(
                label: 'Email',
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 14),

            // Password
            TextFormField(
              controller: _pwdCtrl,
              obscureText: _obscure,
              validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
              decoration: _roundedInputDecoration(
                label: 'Password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Bouton Login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.oceanBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _loading ? null : _handleLogin,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),

            // Lien signup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: _loading ? null : () => context.go('/signup'),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: AppPalette.oceanBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _divider('Or continue with'),
            const SizedBox(height: 16),

            _googleButton(),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: _loading,
            child: Opacity(
              opacity: _loading ? 0.6 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo2.png',
                        width: 120, height: 120, fit: BoxFit.contain),
                    const SizedBox(height: 18),
                    const Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),
                    card,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- petits widgets réutilisables ----------

  Widget _divider(String text) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFE5E7EB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: const TextStyle(color: Color(0xFF6B7280))),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFE5E7EB))),
      ],
    );
  }

  Widget _googleButton() {
    return InkWell(
      onTap: () {
        // TODO: Google sign-in depuis l'app (plus tard)
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/google.png', height: 24),
            const SizedBox(width: 10),
            const Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}
