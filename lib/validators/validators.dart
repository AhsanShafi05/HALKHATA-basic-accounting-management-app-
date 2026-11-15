class Validators {
  // Simple email pattern: text + @ + domain + dot + domain suffix.
  static final RegExp emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  // At least 8 characters, one uppercase, one lowercase, and one digit.
  static final RegExp passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

  // Allows letters, numbers, spaces, dot, apostrophe and hyphen.
  static final RegExp nameRegex =
      RegExp(r"^[A-Za-z][A-Za-z .'-]{1,49}$");

  // Allows a positive amount with up to two decimal places.
  static final RegExp amountRegex =
      RegExp(r'^\d+(\.\d{1,2})?$');

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Enter a valid name (at least 2 letters)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (!passwordRegex.hasMatch(value)) {
      return 'Use 8+ characters, uppercase, lowercase and a number';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    if (!amountRegex.hasMatch(value.trim()) ||
        double.tryParse(value.trim()) == null ||
        double.parse(value.trim()) <= 0) {
      return 'Enter a positive amount (up to 2 decimal places)';
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
