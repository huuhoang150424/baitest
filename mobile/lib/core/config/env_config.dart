import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  }

  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
  static const int sendTimeoutMs = 10000;
}
