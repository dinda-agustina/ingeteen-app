import '../core/config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final ApiService _api;

  AuthService({ApiService? api}) : _api = api ?? ApiService();

  // LOGIN
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _api.post(
        ApiConfig.login,
        body: {
          'username': username,
          'password': password,
          'device_name': 'IngeTeen Android',
        },
      );

      final data = response['data'];

      await _api.saveToken(data['token']);

      return UserModel.fromJson(data['user']);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (_) {
      throw const AuthException(
        'Terjadi kesalahan saat login. Silakan coba lagi.',
      );
    }
  }

  // REGISTER
  Future<UserModel> register(String username, String password) async {
    try {
      final response = await _api.post(
        ApiConfig.register,
        body: {
          'username': username,
          'password': password,
          'password_confirmation': password,
          'device_name': 'IngeTeen Android',
        },
      );

      final data = response['data'];

      // Registrasi tidak langsung membuat sesi login di Flutter.
      // Token registrasi langsung dicabut melalui endpoint logout.
      await _api.saveToken(data['token']);

      try {
        await _api.post(
          ApiConfig.logout,
          withToken: true,
        );
      } finally {
        await _api.deleteToken();
      }

      return UserModel.fromJson(data['user']);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (_) {
      throw const AuthException(
        'Terjadi kesalahan saat registrasi. Silakan coba lagi.',
      );
    }
  }

  // MEMERIKSA USER YANG SEDANG LOGIN
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _api.get(
        ApiConfig.user,
        withToken: true,
      );

      return UserModel.fromJson(response['data']);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _api.deleteToken();
      }

      throw AuthException(e.message);
    } catch (_) {
      throw const AuthException(
        'Tidak dapat memeriksa sesi login.',
      );
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _api.post(
        ApiConfig.logout,
        withToken: true,
      );
    } catch (_) {
      // Token lokal tetap dihapus jika request gagal.
    } finally {
      await _api.deleteToken();
    }
  }
}