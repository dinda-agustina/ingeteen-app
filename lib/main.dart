import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';

void main() => runApp(const IngeTeenApp());

class IngeTeenApp extends StatelessWidget {
  const IngeTeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Segera: TaskProvider dan LabelProvider
      ],
      child: MaterialApp(
        title: 'IngeTeen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}