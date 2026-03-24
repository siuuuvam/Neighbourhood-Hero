import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  static String get backendBaseUrl => dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:3000/api';
  
  static const int karmaPerTask = 50;
  static const int karmaBonusFirstTask = 25;
  static const double defaultSearchRadius = 5.0;
  
  static const int levelThresholdNew = 0;
  static const int levelThresholdActive = 50;
  static const int levelThresholdHero = 200;
  static const int levelThresholdLegend = 500;
  
  static String getKarmaLevel(int points) {
    if (points >= 500) return 'Neighborhood Legend';
    if (points >= 200) return 'Neighborhood Hero';
    if (points >= 50) return 'Active Neighbor';
    return 'New Neighbor';
  }
  
  static String getKarmaLevelIcon(int points) {
    if (points >= 500) return '👑';
    if (points >= 200) return '🦸';
    if (points >= 50) return '⭐';
    return '🌱';
  }
  
  static String get errorGeneric => 'Something went wrong. Please try again.';
  static String get errorLocation => 'Unable to access location services.';
  static String get errorNetwork => 'Please check your internet connection.';
}
