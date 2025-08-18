
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
}
