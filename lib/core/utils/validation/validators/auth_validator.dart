abstract class AuthValidator {
  static const int minPasswordLength = 8;

  static final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/-=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+$");

  /// Check if password length greater than or equals [minPasswordLength],
  /// then returns [True].
  static bool isPasswordLengthValid(String password) {
    return password.length >= minPasswordLength;
  }

  static bool isEmailValid(String email) {
    return emailRegExp.hasMatch(email);
  }

  static bool isOTPValid(String otp) {
    return RegExp(r"^[0-9]{4,6}$").hasMatch(otp);
  }

  /// Check the password contains at least one lower case letter,
  /// upper case letter, number, special character,
  /// and has min length of characters.
  static bool isPasswordValid(String password) {
    return _hasLowerCase(password) &&
        _hasUpperCase(password) &&
        _hasNumber(password) &&
        _hasSpecialCharacters(password) &&
        isPasswordLengthValid(password);
  }

  static bool _hasLowerCase(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  static bool _hasUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  static bool _hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  static bool _hasSpecialCharacters(String password) {
    return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}
