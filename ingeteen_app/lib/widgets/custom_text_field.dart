import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: widget.isPassword && _obscure,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 18, color: AppColors.textGrey)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            enabledBorder: _border(hasError ? AppColors.urgent : AppColors.border),
            focusedBorder: _border(hasError ? AppColors.urgent : AppColors.primary),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.urgent),
            const SizedBox(width: 4),
            Expanded(
              child: Text(widget.errorText!,
                  style: const TextStyle(fontSize: 10, color: AppColors.urgent)),
            ),
          ]),
        ],
      ],
    );
  }
}