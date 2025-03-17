import 'package:flutter/material.dart';

class ReusableDropdown extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;
  final Color? fillColor;
  final Color? borderColor;

  const ReusableDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.fillColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: fillColor ?? Colors.pink[50], // Default to light pink
        borderRadius: BorderRadius.circular(30.0), // Rounded corners
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300, // Default light grey
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(
            hintText,
            style: const TextStyle(color: Colors.grey),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white, // Dropdown background color
        ),
      ),
    );
  }
}
