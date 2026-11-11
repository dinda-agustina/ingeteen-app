class Validators {
  Validators._();

  static String? username(String v) {
    final text = v.trim();
    if (text.length < 4) return 'Username minimal 4 karakter.';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(text)) {
      return 'Gunakan huruf, angka, atau underscore.';
    }
    return null;
  }

  static String? password(String v) {
    final valid = v.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(v) &&
        RegExp(r'\d').hasMatch(v);
    return valid ? null : 'Minimal 8 karakter, gunakan huruf dan angka.';
  }

  static String? confirmPassword(String password, String confirm) =>
      password == confirm ? null : 'Konfirmasi password belum sama.';
}