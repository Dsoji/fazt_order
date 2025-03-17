import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../res/app_colors.dart';

class CustomFormTextField extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final String fieldName;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final Color? fillColor;
  final FocusNode? focus;
  final Widget? suffixIcon; // Added suffixIcon

  const CustomFormTextField({
    super.key,
    this.labelText,
    required this.hintText,
    required this.fieldName,
    required this.keyboardType,
    this.controller,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.fillColor = Colors.transparent,
    this.focus,
    this.suffixIcon, // Optional suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral200,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: FormBuilderTextField(
              focusNode: focus,
              readOnly: readOnly,
              name: fieldName,
              keyboardType: keyboardType,
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                fillColor: fillColor,
                hintText: hintText,
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
                suffixIcon: suffixIcon, // Adding suffixIcon here
              ),
              onTap: onTap,
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
