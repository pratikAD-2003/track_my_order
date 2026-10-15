/// Central configuration for Google Maps, Google Places (New), and Routes API.
class MapsConfig {
  /// Google Cloud API key with Maps SDK for Android & iOS, Places API (New),
  /// and Routes API enabled.
  static String apiKey = 'AIzaSyCZSVob1cZVp0tJNqI8tbVf150kUZ8_3fs';

  /// Default fallback location (e.g. New Delhi / Bhopal) if GPS is disabled
  static const double defaultLatitude = 23.2599;
  static const double defaultLongitude = 77.4126;
  static const String defaultCity = 'Bhopal, MP';
}
