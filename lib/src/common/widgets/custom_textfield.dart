import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../res/app_colors.dart';

class CustomFormTextField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final String fieldName;
  final bool readOnly;
  final bool isPassword; // 👈 NEW
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onTap;
  final Color? fillColor;
  final FocusNode? focus;
  final Widget? suffixIcon;

  const CustomFormTextField({
    super.key,
    this.labelText,
    required this.hintText,
    required this.fieldName,
    required this.keyboardType,
    this.controller,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.fillColor = Colors.transparent,
    this.focus,
    this.onChanged,
    this.isPassword = false, // 👈 default false
    this.suffixIcon,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null && widget.labelText!.isNotEmpty)
            Text(
              widget.labelText!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral200,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 4),
          FormBuilderTextField(
            focusNode: widget.focus,
            readOnly: widget.readOnly,
            name: widget.fieldName,
            keyboardType: widget.keyboardType,
            controller: widget.controller,
            validator: widget.validator,
            onChanged: widget.onChanged,
            obscureText: widget.isPassword ? _obscureText : false,
            onTap: widget.onTap,
            decoration: InputDecoration(
              fillColor: widget.fillColor,
              hintText: widget.hintText,
              filled: true,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.neutral800, width: 0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFieldSubmitted;
  final Color color;

  const NumberField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onFieldSubmitted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          fillColor: color,
          filled: true,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.brand980,
            ),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.brand980,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.brand980,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            onFieldSubmitted();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Empty';
          }
          return null;
        },
      ),
    );
  }
}
