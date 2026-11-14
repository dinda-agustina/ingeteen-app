import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/validators.dart';
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

  bool _submitted = false;
  String? _serverError;

  String? get _usernameError =>
      !_submitted ? null : Validators.username(_usernameC.text);

  String? get _passwordError =>
      !_submitted ? null : Validators.password(_passwordC.text);

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    setState(() => _serverError = null);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _submitted = true;
      _serverError = null;
    });

    if (_usernameError != null || _passwordError != null) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _usernameC.text.trim(),
      _passwordC.text,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
      );
    } else {
      setState(() => _serverError = auth.error);
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
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Username',
                      hint: '',
                      controller: _usernameC,
                      prefixIcon: Icons.person_outline,
                      errorText: _usernameError,
                      onChanged: _onChanged,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      hint: '',
                      controller: _passwordC,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      errorText: _passwordError ?? _serverError,
                      onChanged: _onChanged,
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
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.register,
                      ),
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