import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/maps_config.dart';

class RouteInfo {
  final int durationMinutes;
  final double distanceKm;
  final String formattedDistance;
  final String formattedEta;
  final List<LatLng> polylinePoints;

  RouteInfo({
    required this.durationMinutes,
    required this.distanceKm,
    required this.formattedDistance,
    required this.formattedEta,
    required this.polylinePoints,
  });
}

class RoutesService {
  static final RoutesService _instance = RoutesService._internal();
  factory RoutesService() => _instance;
  RoutesService._internal();

  /// Computes real-time route, distance, and travel duration via Google Maps Directions API
  /// Falls back to Haversine distance calculation if offline or API restricted
  Future<RouteInfo> computeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destLat,$destLng&key=${MapsConfig.apiKey}&mode=driving',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status']?.toString();
        if (status == 'OK') {
          final routes = data['routes'] as List<dynamic>? ?? [];
          if (routes.isNotEmpty) {
            final first = routes.first;
            final legs = first['legs'] as List<dynamic>? ?? [];
            double distanceMeters = 0.0;
            int seconds = 300;

            if (legs.isNotEmpty) {
              final leg = legs.first;
              distanceMeters = (leg['distance']?['value'] as num?)?.toDouble() ?? 0.0;
              seconds = (leg['duration']?['value'] as num?)?.toInt() ?? 300;
            }

            final durationMins = max(1, (seconds / 60).ceil());
            final distKm = distanceMeters / 1000.0;

            final encoded = first['overview_polyline']?['points']?.toString() ?? '';
            final decodedPoints = _decodePolyline(encoded);

            return RouteInfo(
              durationMinutes: durationMins,
              distanceKm: distKm,
              formattedDistance: '${distKm.toStringAsFixed(1)} km',
              formattedEta: '~$durationMins mins',
              polylinePoints: decodedPoints.isNotEmpty
                  ? decodedPoints
                  : [
                      LatLng(originLat, originLng),
                      LatLng(destLat, destLng),
                    ],
            );
          }
        }
      }
    } catch (_) {}

    // Fallback: Haversine distance via Geolocator
    return _computeFallbackRoute(originLat, originLng, destLat, destLng);
  }

  RouteInfo _computeFallbackRoute(
    double originLat,
    double originLng,
    double destLat,
    double destLng,
  ) {
    final straightMeters = Geolocator.distanceBetween(originLat, originLng, destLat, destLng);
    
    // Apply Uber / Rapido city road circuitous factor (1.3x)
    final roadMeters = straightMeters * 1.3;
    final distKm = roadMeters / 1000.0;

    int durationMins;
    String etaText;

    if (roadMeters < 60) {
      durationMins = 0;
      etaText = 'Arriving';
    } else {
      // 400 meters per minute (~24 km/h average motorcycle city speed)
      durationMins = max(1, (roadMeters / 400).round());
      etaText = durationMins == 1 ? '1 min' : '~$durationMins mins';
    }

    return RouteInfo(
      durationMinutes: durationMins,
      distanceKm: distKm,
      formattedDistance: distKm < 1 ? '${roadMeters.round()} m' : '${distKm.toStringAsFixed(1)} km',
      formattedEta: etaText,
      polylinePoints: [
        LatLng(originLat, originLng),
        LatLng(destLat, destLng),
      ],
    );
  }

  /// Decodes Google Encoded Polyline algorithm string into geographic coordinates
  List<LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) return [];
    final List<LatLng> poly = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}
