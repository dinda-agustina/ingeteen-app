import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double fontSize;
  final bool vertical;

  const AppLogo({super.key, this.fontSize = 16, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    // TODO: ganti Icon dengan logo asli (Image.asset('assets/images/logo.png'))
    final icon = Icon(Icons.sticky_note_2_rounded,
        color: AppColors.primary, size: fontSize * 1.8);
    final text = RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        children: const [
          TextSpan(text: 'Inge', style: TextStyle(color: AppColors.textDark)),
          TextSpan(text: 'Teen', style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );

    return vertical
        ? Column(mainAxisSize: MainAxisSize.min, children: [icon, const SizedBox(height: 8), text])
        : Row(mainAxisSize: MainAxisSize.min, children: [icon, const SizedBox(width: 8), text]);
  }
}