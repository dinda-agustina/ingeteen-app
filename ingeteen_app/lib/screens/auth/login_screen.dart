import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final username = _usernameC.text.trim();
    final password = _passwordC.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Username dan password wajib diisi.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(username, password);
    if (!mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      setState(() => _error = auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(fontSize: 16),
                    const SizedBox(height: 28),
                    const Text('Selamat datang\nkembali!',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
                    const SizedBox(height: 8),
                    const Text('Masuk untuk melanjutkan catatan dan jadwal tugasmu.',
                        style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Username',
                      hint: '',
                      controller: _usernameC,
                      prefixIcon: Icons.person_outline,
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      hint: '',
                      controller: _passwordC,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      errorText: _error,
                      onChanged: _clearError,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Login',
                      icon: Icons.login,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const Spacer(),
                    const Center(
                      child: Text('Belum punya akun?',
                          style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Daftar',
                      icon: Icons.person_add_alt_1_outlined,
                      isOutlined: true,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}