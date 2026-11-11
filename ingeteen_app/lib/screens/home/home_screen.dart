import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hi, ${user?.username ?? 'User'}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (_) => false);
              },
              child: const Text('Keluar (sementara)'),
            ),
          ],
        ),
      ),
    );
  }
}