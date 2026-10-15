/// Central configuration for Google Maps, Google Places (New), and Routes API.
class MapsConfig {
  /// Google Cloud API key with Maps SDK for Android & iOS, Places API (New),
  /// and Routes API enabled.
  static String apiKey = 'AIzaSyDNRF-Lwuzr8WvI7Kz7H-KFXoV1H9kn5Pg';

  /// Default fallback location (e.g. New Delhi / Bhopal) if GPS is disabled
  static const double defaultLatitude = 23.2599;
  static const double defaultLongitude = 77.4126;
  static const String defaultCity = 'Bhopal, MP';
}
