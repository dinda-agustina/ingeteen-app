import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/app_result_dialog.dart';

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
    // Hindari submit berulang saat request sedang berjalan.
    if (context.read<AuthProvider>().isLoading) return;

    FocusScope.of(context).unfocus();

    final username = _usernameC.text.trim();
    final password = _passwordC.text;

    // Validasi input
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Username dan password wajib diisi.';
      });
      return;
    }

    final auth = context.read<AuthProvider>();

    final ok = await auth.login(username, password);

    if (!mounted) return;

    if (ok) {

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
      );
    } else {
      await showAppResultDialog(
        context,
        isSuccess: false,
        title: 'Login Gagal',
        message: auth.error ??
            'Username atau password tidak sesuai. Silakan coba lagi.',
        buttonText: 'Coba Lagi',
      );
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
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(fontSize: 16),
                    const SizedBox(height: 28),
                    const Text(
                      'Selamat datang\nkembali!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk untuk melanjutkan catatan dan jadwal tugasmu.',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
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
                      child: Text(
                        'Belum punya akun?',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Daftar',
                      icon: Icons.person_add_alt_1_outlined,
                      isOutlined: true,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
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
