import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String obscuringCharacter;
  final String? hintText;

  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  const GlassTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.hintText,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        /// Glassmorphic Input Field
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                obscureText: obscureText,
                obscuringCharacter: obscuringCharacter,
                enabled: enabled,
                readOnly: readOnly,
                maxLines: obscureText ? 1 : maxLines,
                minLines: minLines,
                maxLength: maxLength,
                autofillHints: autofillHints,
                inputFormatters: inputFormatters,

                onChanged: onChanged,
                onSaved: onSaved,
                validator: validator,
                onFieldSubmitted: onFieldSubmitted,

                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,

                decoration: InputDecoration(
                  hintText: hintText ?? "Enter $label",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  counterText: '',
                  prefixIcon: prefixIcon,
                  suffixIcon: suffixIcon,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
