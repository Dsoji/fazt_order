class Validators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }

    final upperCaseRegex = RegExp(r'[A-Z]');
    final lowerCaseRegex = RegExp(r'[a-z]');
    final numberRegex = RegExp(r'\d');
    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    if (!upperCaseRegex.hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    }

    if (!lowerCaseRegex.hasMatch(value)) {
      return "Password must contain at least one lowercase letter";
    }

    if (!numberRegex.hasMatch(value)) {
      return "Password must contain at least one number";
    }

    if (!specialCharRegex.hasMatch(value)) {
      return "Password must contain at least one special character";
    }

    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^\+?\d+$').hasMatch(digitsOnly)) {
      return "Enter a valid phone number";
    }
    final digitCount = digitsOnly.replaceAll('+', '').length;
    if (digitCount < 10 || digitCount > 15) {
      return "Enter a valid phone number";
    }
    return null;
  }

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  /// ✅ New generic min/max validator
  static String? minMaxValidator(
    String? value,
    String fieldName, {
    int? min,
    int? max,
  }) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    if (min != null && value.length < min) {
      return "$fieldName must be at least $min characters";
    }
    if (max != null && value.length > max) {
      return "$fieldName must be at most $max characters";
    }
    return null;
  }
}
