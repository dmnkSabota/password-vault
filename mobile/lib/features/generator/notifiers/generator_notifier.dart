import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PasswordStrength { veryWeak, weak, fair, strong, veryStrong }

extension PasswordStrengthX on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  double get fraction {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 0.1;
      case PasswordStrength.weak:
        return 0.3;
      case PasswordStrength.fair:
        return 0.55;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}

class GeneratorState {
  final String password;
  final int length;
  final bool useUppercase;
  final bool useLowercase;
  final bool useNumbers;
  final bool useSymbols;
  final PasswordStrength strength;

  const GeneratorState({
    this.password = '',
    this.length = 16,
    this.useUppercase = true,
    this.useLowercase = true,
    this.useNumbers = true,
    this.useSymbols = false,
    this.strength = PasswordStrength.fair,
  });

  GeneratorState copyWith({
    String? password,
    int? length,
    bool? useUppercase,
    bool? useLowercase,
    bool? useNumbers,
    bool? useSymbols,
    PasswordStrength? strength,
  }) {
    return GeneratorState(
      password: password ?? this.password,
      length: length ?? this.length,
      useUppercase: useUppercase ?? this.useUppercase,
      useLowercase: useLowercase ?? this.useLowercase,
      useNumbers: useNumbers ?? this.useNumbers,
      useSymbols: useSymbols ?? this.useSymbols,
      strength: strength ?? this.strength,
    );
  }
}

class GeneratorNotifier extends Notifier<GeneratorState> {
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _numbers = '0123456789';
  static const _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  @override
  GeneratorState build() {
    Future.microtask(generate);
    return const GeneratorState();
  }

  void setLength(int length) {
    state = state.copyWith(length: length);
    generate();
  }

  void toggleUppercase(bool value) {
    state = state.copyWith(useUppercase: value);
    generate();
  }

  void toggleLowercase(bool value) {
    state = state.copyWith(useLowercase: value);
    generate();
  }

  void toggleNumbers(bool value) {
    state = state.copyWith(useNumbers: value);
    generate();
  }

  void toggleSymbols(bool value) {
    state = state.copyWith(useSymbols: value);
    generate();
  }

  void generate() {
    final charset = _buildCharset();
    if (charset.isEmpty) {
      state = state.copyWith(
        password: '',
        strength: PasswordStrength.veryWeak,
      );
      return;
    }

    final rng = Random.secure();
    final password = List.generate(
      state.length,
      (_) => charset[rng.nextInt(charset.length)],
    ).join();

    state = state.copyWith(
      password: password,
      strength: _calculateStrength(password),
    );
  }

  String _buildCharset() {
    final buffer = StringBuffer();
    if (state.useUppercase) buffer.write(_uppercase);
    if (state.useLowercase) buffer.write(_lowercase);
    if (state.useNumbers) buffer.write(_numbers);
    if (state.useSymbols) buffer.write(_symbols);
    return buffer.toString();
  }

  PasswordStrength _calculateStrength(String password) {
    final length = password.length;
    int charsetCount = 0;
    if (state.useUppercase) charsetCount++;
    if (state.useLowercase) charsetCount++;
    if (state.useNumbers) charsetCount++;
    if (state.useSymbols) charsetCount++;

    int score = 0;
    if (length >= 8) score++;
    if (length >= 12) score++;
    if (length >= 16) score++;
    if (length >= 20) score++;
    if (charsetCount >= 2) score++;
    if (charsetCount >= 3) score++;
    if (charsetCount == 4) score++;

    if (score <= 1) return PasswordStrength.veryWeak;
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }
}
