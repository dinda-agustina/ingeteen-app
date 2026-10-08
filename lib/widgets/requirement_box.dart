import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RequirementItem {
  final String label;
  final bool met;
  const RequirementItem(this.label, this.met);
}

class RequirementBox extends StatelessWidget {
  final List<RequirementItem> items;
  const RequirementBox({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Syarat akun',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: items
                .map((e) => Text(
                      '✓ ${e.label}',
                      style: TextStyle(
                        fontSize: 9,
                        color: e.met ? const Color(0xFF2E7D32) : AppColors.textGrey,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}