import 'package:flutter/material.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/label/label_screen.dart';
import '../../screens/trash/trash_screen.dart';
import '../../screens/archive/archive_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const label = '/label';
  static const trash = '/trash';
  static const archive = '/archive';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
        label: (_) => const LabelScreen(),
        trash: (_) => const TrashScreen(),
        archive: (_) => const ArchiveScreen(),
      };
}