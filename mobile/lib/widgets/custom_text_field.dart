import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.suffixIcon,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
