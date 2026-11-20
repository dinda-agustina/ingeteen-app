
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';
  static const String user = '$baseUrl/user';

  static const String tasks = '$baseUrl/tasks';
  static const String labels = '$baseUrl/labels';
}