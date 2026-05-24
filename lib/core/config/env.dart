import 'package:flutter/services.dart';

class Env {
  static final Map<String, String> _env = {};

  static Future<void> load() async {
    try {
      final content = await rootBundle.loadString('.env');
      for (var line in content.split('\n')) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final index = line.indexOf('=');
        if (index != -1) {
          final key = line.substring(0, index).trim();
          final value = line.substring(index + 1).trim();
          _env[key] = value.replaceAll('"', '').replaceAll("'", "");
        }
      }
    } catch (e) {
      // .env file not found or couldn't be loaded, will fallback gracefully
    }
  }

  static String get(String key, {String defaultValue = ''}) {
    return _env[key] ?? defaultValue;
  }
}
