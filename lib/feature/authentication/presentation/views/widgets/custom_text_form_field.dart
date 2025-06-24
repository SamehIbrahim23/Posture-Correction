import 'package:flutter/material.dart';

import '../../../../../core/utils/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
    required this.onChanged,
    this.textEditingController,
  });
  final String hint;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String) onChanged;
  final TextEditingController? textEditingController;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      obscureText: obscure,
      cursorColor: AppColors.primaryColor,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),
        hintFadeDuration: const Duration(milliseconds: 300),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        enabledBorder: buildBorder(
          color: Colors.grey.shade400,
        ),
        focusedBorder: buildBorder(
          color: Colors.grey.shade400,
        ),
        errorBorder: buildBorder(
          color: Colors.redAccent.shade100,
        ),
        focusedErrorBorder: buildBorder(
          color: Colors.redAccent.shade100,
        ),
      ),
    );
  }

  OutlineInputBorder buildBorder({
    required Color color,
  }) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
      ),
      borderRadius: BorderRadius.circular(26.0),
    );
  }
}
