import '../models/user_model.dart';
import 'dummy_data.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class AuthService {
  // Daftar akun dummy (username -> password)
  static final Map<String, String> _passwords = {
    DummyData.user.username: DummyData.demoPassword,
  };
  static final List<UserModel> _users = [DummyData.user];

  Future<UserModel> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final key = username.toLowerCase();
    if (_passwords[key] != password) {
      throw const AuthException('Username atau password tidak sesuai.');
    }
    return _users.firstWhere((u) => u.username.toLowerCase() == key);
  }

  Future<UserModel> register(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final key = username.toLowerCase();
    if (_passwords.containsKey(key)) {
      throw const AuthException('Username sudah digunakan.');
    }
    final user = UserModel(id: _users.length + 1, username: username);
    _users.add(user);
    _passwords[key] = password;
    return user;
  }
}