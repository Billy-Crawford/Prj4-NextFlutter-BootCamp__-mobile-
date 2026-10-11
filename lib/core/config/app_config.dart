import 'package:flutter/foundation.dart';

class AppConfig {
  /// Base API URL for Flask backend:
  /// - Android emulator uses 10.0.2.2 to reach host machine's localhost
  /// - Real Android device / Linux / Web uses localhost or network IP
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000/api/v1';
      default:
        return 'http://localhost:5000/api/v1';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
