import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/requirement_box.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _submitted = false;
  String? _serverError; // mis. "Username sudah digunakan."

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  String? get _usernameError => !_submitted
      ? null
      : (Validators.username(_usernameC.text) ?? _serverError);
  String? get _passwordError =>
      !_submitted ? null : Validators.password(_passwordC.text);
  String? get _confirmError => !_submitted
      ? null
      : Validators.confirmPassword(_passwordC.text, _confirmC.text);

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_usernameError != null || _passwordError != null || _confirmError != null) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_usernameC.text.trim(), _passwordC.text);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')),
      );
      Navigator.pop(context);
    } else {
      setState(() => _serverError = auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final password = _passwordC.text;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.arrow_back, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const AppLogo(fontSize: 16),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Buat akun pelajar',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Satu langkah lagi menuju hari yang lebih teratur.',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Username',
                hint: '',
                controller: _usernameC,
                prefixIcon: Icons.person_outline,
                errorText: _usernameError,
                onChanged: (_) => setState(() => _serverError = null),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                hint: '',
                controller: _passwordC,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                errorText: _passwordError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Konfirmasi Password',
                hint: '',
                controller: _confirmC,
                prefixIcon: Icons.shield_outlined,
                isPassword: true,
                errorText: _confirmError,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              RequirementBox(items: [
                RequirementItem('Username valid',
                    Validators.username(_usernameC.text) == null),
                RequirementItem('8+ karakter, huruf dan angka',
                    Validators.password(password) == null),
                RequirementItem('Password harus sama',
                    password.isNotEmpty && password == _confirmC.text),
              ]),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Daftar Sekarang',
                icon: Icons.person_add_alt_1_outlined,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sudah punya akun? ',
                        style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Kembali ke Login',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD4943A))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}