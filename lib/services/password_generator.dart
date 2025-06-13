import 'dart:math';

class PasswordGenerator {
  static String generate({
    int length = 12,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    String chars = '';
    if (includeUppercase) chars += upper;
    if (includeLowercase) chars += lower;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    if (chars.isEmpty) return '';

    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
