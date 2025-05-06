String? textValidator({required String? value, required String fieldName}) {
  if (value == null || value.isEmpty) {
    return "Enter your $fieldName";
  }
  return null;
}

String? usernameValidator({required String? value}) {
  if (value == null || value.isEmpty) {
    return "Enter your username";
  }

  final regex = RegExp(r'^[a-zA-Z0-9_]+$');
  if (!regex.hasMatch(value)) {
    return "Username can only contain letters, numbers, and underscores";
  }

  if (value.length < 3 || value.length > 20) {
    return "Username must be between 3 and 20 characters";
  }

  return null;
}

String? passwordValidator({required String? value}) {
  if (value == null || value.isEmpty) {
    return "Enter your password";
  }

  // check for minimum password requirements here

  return null;
}

String? confirmPasswordValidator({
  required String? value,
  required String password,
}) {
  if (value == null || value.isEmpty) {
    return "Enter your password again";
  }
  if (value != password) {
    return "Passwords do not match";
  }
  return null;
}

String? urlValidator({required String? value}) {
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.isAbsolute) {
    return "Enter a valid URL";
  }

  return null;
}

String? emailValidator({required String? value}) {
  if (value == null || value.isEmpty) return "Enter your email";

  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(value)) {
    return "Enter a valid email address";
  }

  return null;
}
