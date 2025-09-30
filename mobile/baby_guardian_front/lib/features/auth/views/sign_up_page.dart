import 'package:baby_guardian_front/shared/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_guardian_front/features/auth/service/auth_api.dart';

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
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthApi.signup(
        fullName: _nameCtrl.text,
        email: _emailCtrl.text,
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ----- UI -----
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    InputDecoration _dec(String label, IconData icon, {Widget? suffix}) {
      return InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: AppPalette.oceanBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AbsorbPointer(
            absorbing: _loading,
            child: Opacity(
              opacity: _loading ? 0.6 : 1,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo2.png',
                        width: 150, height: 150, fit: BoxFit.contain),
                    const SizedBox(height: 30),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full name
                    TextFormField(
                      controller: _nameCtrl,
                      focusNode: _nameFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_emailFocus),
                      decoration: _dec('Full Name', Icons.person_outline),
                      validator: (v) =>
                          (v == null || v.trim().length < 3)
                              ? 'Enter your full name'
                              : null,
                    ),
                    const SizedBox(height: 14),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_pwdFocus),
                      decoration: _dec('Email', Icons.email_outlined),
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        return re.hasMatch(email) ? null : 'Invalid email';
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password
                    TextFormField(
                      controller: _pwdCtrl,
                      focusNode: _pwdFocus,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _doSignUp(),
                      decoration: _dec(
                        'Password',
                        Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() {
                            _obscure = !_obscure;
                          }),
                        ),
                      ),
                      validator: (v) {
                        final s = v ?? '';
                        if (s.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.oceanBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading ? null : _doSignUp,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppPalette.oceanBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    _divider('Or sign up with'),
                    const SizedBox(height: 14),

                    // Google button (placeholder)
                    _googleButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(String text) => Row(
        children: [
          Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(text),
          ),
          Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
        ],
      );

  Widget _googleButton() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Image.asset('assets/images/google.png', height: 28),
      );
}
