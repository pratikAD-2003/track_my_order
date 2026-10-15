import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../config/maps_config.dart';
import '../models/place_location.dart';

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;
  final double? lat;
  final double? lng;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
    this.lat,
    this.lng,
  });
}

class PlacesService {
  static final PlacesService _instance = PlacesService._internal();
  factory PlacesService() => _instance;
  PlacesService._internal();

  final Geocoding _geocoding = Geocoding();

  String? _currentSessionToken;

  /// Generates or retrieves a session token for session management.
  String getSessionToken() {
    _currentSessionToken ??= '${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
    return _currentSessionToken!;
  }

  /// Resets the session token.
  void resetSessionToken() {
    _currentSessionToken = null;
  }

  String _cleanSecondaryText(String secondary) {
    var s = secondary.trim();
    if (s.endsWith(', India') || s.endsWith(' India')) {
      s = s.replaceAll(RegExp(r',\s*India$'), '').trim();
    }
    if (s.contains(',')) {
      final parts = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parts.length > 2) {
        s = parts.take(2).join(', ');
      }
    }
    return s;
  }

  /// Search places using Google Places Autocomplete (New) and Text Search (New) with session tokens,
  /// 20km location bias, and India region restriction.
  Future<List<PlacePrediction>> searchAutocomplete(String query, {String? sessionToken}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    double centerLat = MapsConfig.defaultLatitude;
    double centerLng = MapsConfig.defaultLongitude;
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        centerLat = pos.latitude;
        centerLng = pos.longitude;
      }
    } catch (_) {}

    final token = sessionToken ?? getSessionToken();

    // 1. Try Google Places Autocomplete API (New)
    try {
      final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
      final bodyMap = {
        'input': cleanQuery,
        'includedRegionCodes': ['in'],
        'locationBias': {
          'circle': {
            'center': {
              'latitude': centerLat,
              'longitude': centerLng,
            },
            'radius': 20000.0,
          },
        },
        'includeQueryPredictions': false,
        'sessionToken': token,
      };

      debugPrint('[PlacesService] Requesting Autocomplete (New) for "$cleanQuery"');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': MapsConfig.apiKey,
            },
            body: jsonEncode(bodyMap),
          )
          .timeout(const Duration(seconds: 4));

      debugPrint('[PlacesService] Autocomplete (New) status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['suggestions'] as List<dynamic>? ?? [];

        final results = <PlacePrediction>[];
        for (final item in suggestions) {
          final pred = item['placePrediction'];
          if (pred != null) {
            final placeId = pred['placeId'] ?? pred['place']?.toString().replaceFirst('places/', '') ?? '';
            final structured = pred['structuredFormat'];
            final fullText = pred['text']?['text']?.toString() ?? '';

            String mainText = '';
            String secondaryText = '';

            if (structured != null) {
              mainText = structured['mainText']?['text']?.toString() ?? '';
              secondaryText = _cleanSecondaryText(structured['secondaryText']?['text']?.toString() ?? '');
            }

            if (mainText.isEmpty && fullText.isNotEmpty) {
              if (fullText.contains(',')) {
                final parts = fullText.split(',');
                mainText = parts.first.trim();
                secondaryText = _cleanSecondaryText(parts.skip(1).join(', '));
              } else {
                mainText = fullText;
              }
            }

            if (mainText.isNotEmpty) {
              results.add(PlacePrediction(
                placeId: placeId,
                mainText: mainText,
                secondaryText: secondaryText,
                fullText: fullText.isNotEmpty ? fullText : '$mainText, $secondaryText',
              ));
            }
          }
        }
        if (results.isNotEmpty) return results;
      } else {
        debugPrint('[PlacesService] Autocomplete (New) error body: ${response.body}');
      }
    } catch (e) {
      debugPrint('[PlacesService] Google Places Autocomplete (New) exception: $e');
    }

    // 2. Try Google Places Text Search API (New) as fallback
    try {
      final textSearchUrl = Uri.parse('https://places.googleapis.com/v1/places:searchText');
      debugPrint('[PlacesService] Requesting Text Search (New) for "$cleanQuery"');
      final response = await http
          .post(
            textSearchUrl,
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': MapsConfig.apiKey,
              'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location',
            },
            body: jsonEncode({
              'textQuery': cleanQuery,
              'includedRegionCodes': ['in'],
              'locationBias': {
                'circle': {
                  'center': {
                    'latitude': centerLat,
                    'longitude': centerLng,
                  },
                  'radius': 20000.0,
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 4));

      debugPrint('[PlacesService] Text Search (New) status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final places = data['places'] as List<dynamic>? ?? [];
        if (places.isNotEmpty) {
          final results = <PlacePrediction>[];
          for (final place in places) {
            final placeId = place['id']?.toString() ?? '';
            final displayName = place['displayName']?['text']?.toString() ?? cleanQuery;
            final address = place['formattedAddress']?.toString() ?? displayName;
            final location = place['location'];
            final lat = (location?['latitude'] as num?)?.toDouble();
            final lng = (location?['longitude'] as num?)?.toDouble();

            String mainText = displayName;
            String secondaryText = address;
            if (address.contains(',')) {
              final parts = address.split(',');
              mainText = parts.first.trim();
              secondaryText = _cleanSecondaryText(parts.skip(1).join(', '));
            }

            results.add(PlacePrediction(
              placeId: placeId,
              mainText: mainText,
              secondaryText: secondaryText,
              fullText: address,
              lat: lat,
              lng: lng,
            ));
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (e) {
      debugPrint('[PlacesService] Google Places Text Search (New) exception: $e');
    }

    // 3. Fallback to Flutter geocoding package
    try {
      return await _fallbackGeocodingSearch(cleanQuery);
    } catch (_) {}

    return [];
  }

  /// Fetches place coordinates and formatted address by Place ID via Google Places API (New) Place Details.
  Future<PlaceLocation?> getPlaceDetails(String placeId, {String? defaultTitle, PlacePrediction? prediction, String? sessionToken}) async {
    if (prediction != null && prediction.lat != null && prediction.lng != null) {
      return PlaceLocation(
        title: prediction.mainText,
        address: prediction.fullText,
        latitude: prediction.lat!,
        longitude: prediction.lng!,
        placeId: placeId,
      );
    }

    if (placeId.startsWith('geo_')) {
      final parts = placeId.replaceFirst('geo_', '').split('_');
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0]) ?? MapsConfig.defaultLatitude;
        final lng = double.tryParse(parts[1]) ?? MapsConfig.defaultLongitude;
        return PlaceLocation(
          title: defaultTitle ?? 'Selected Location',
          address: defaultTitle ?? 'Selected Location',
          latitude: lat,
          longitude: lng,
          placeId: placeId,
        );
      }
    }

    // Google Places Place Details (New)
    try {
      var urlStr = 'https://places.googleapis.com/v1/places/$placeId';
      final token = sessionToken ?? _currentSessionToken;
      if (token != null && token.isNotEmpty) {
        urlStr += '?sessionToken=$token';
      }
      final url = Uri.parse(urlStr);
      debugPrint('[PlacesService] Fetching Place Details (New) for $placeId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': MapsConfig.apiKey,
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['displayName']?['text'] ?? defaultTitle ?? 'Selected Location';
        final formattedAddress = data['formattedAddress'] ?? title;
        final loc = data['location'];
        final lat = (loc?['latitude'] as num?)?.toDouble();
        final lng = (loc?['longitude'] as num?)?.toDouble();

        if (lat != null && lng != null) {
          return PlaceLocation(
            title: title,
            address: formattedAddress,
            latitude: lat,
            longitude: lng,
            placeId: placeId,
          );
        }
      }
    } catch (e) {
      debugPrint('[PlacesService] Place Details (New) exception: $e');
    }

    // Fallback: Geocode title or defaultTitle
    if (defaultTitle != null && defaultTitle.isNotEmpty) {
      return await geocodeAddress(defaultTitle);
    }

    return null;
  }

  /// Geocodes an address string to LatLng coordinates
  Future<PlaceLocation?> geocodeAddress(String address) async {
    try {
      final locations = await _geocoding.locationFromAddress(address).timeout(
        const Duration(seconds: 4),
      );
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return PlaceLocation(
          title: address.split(',').first,
          address: address,
          latitude: loc.latitude,
          longitude: loc.longitude,
        );
      }
    } catch (e) {
      debugPrint('[PlacesService] Geocode address error: $e');
    }
    return null;
  }

  /// Reverse geocodes Lat/Lng coordinates into a human-readable PlaceLocation
  Future<PlaceLocation?> reverseGeocode(double lat, double lng) async {
    try {
      // 1. Try Google Geocoding API for reverse geocoding
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${MapsConfig.apiKey}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          final first = results.first;
          final formattedAddress = first['formatted_address']?.toString() ?? '$lat, $lng';
          String title = formattedAddress.split(',').first.trim();
          return PlaceLocation(
            title: title,
            address: formattedAddress,
            latitude: lat,
            longitude: lng,
          );
        }
      }
    } catch (e) {
      debugPrint('[PlacesService] Google reverse geocode exception: $e');
    }

    // 2. Fallback to Flutter geocoding package
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 5),
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final titleParts = [
          if (p.name != null && p.name!.isNotEmpty) p.name,
          if (p.subLocality != null && p.subLocality!.isNotEmpty && p.subLocality != p.name)
            p.subLocality,
        ];
        final title = titleParts.isNotEmpty ? titleParts.join(', ') : 'Current Location';

        final fullAddressParts = [
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
        ];

        final formattedAddress = fullAddressParts.isNotEmpty
            ? fullAddressParts.toSet().join(', ')
            : '$lat, $lng';

        return PlaceLocation(
          title: title,
          address: formattedAddress,
          latitude: lat,
          longitude: lng,
        );
      }
    } catch (e) {
      debugPrint('[PlacesService] Reverse geocode error: $e');
    }

    return null;
  }

  /// Fetches current device GPS location and converts it to a readable PlaceLocation
  Future<PlaceLocation?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[PlacesService] Location service disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('[PlacesService] Location permission not granted');
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );

      return await reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('[PlacesService] Error fetching current location: $e');
      return null;
    }
  }

  /// Fallback search using Flutter's native `geocoding` package with city context
  Future<List<PlacePrediction>> _fallbackGeocodingSearch(String query) async {
    final clean = query.trim();
    List<Location> locations = [];
    try {
      locations = await _geocoding.locationFromAddress(clean).timeout(const Duration(seconds: 3));
    } catch (_) {}

    if (locations.isEmpty && !clean.toLowerCase().contains('bhopal')) {
      try {
        locations = await _geocoding.locationFromAddress('$clean, Bhopal, India').timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    try {
      final predictions = <PlacePrediction>[];
      for (int i = 0; i < locations.length && i < 5; i++) {
        final loc = locations[i];
        final marks = await _geocoding.placemarkFromCoordinates(loc.latitude, loc.longitude);
        if (marks.isNotEmpty) {
          final p = marks.first;
          final main = p.name ?? p.subLocality ?? clean;
          final sec = _cleanSecondaryText('${p.locality ?? ''}, ${p.administrativeArea ?? ''}');
          predictions.add(PlacePrediction(
            placeId: 'geo_${loc.latitude}_${loc.longitude}',
            mainText: main,
            secondaryText: sec,
            fullText: '$main, $sec',
            lat: loc.latitude,
            lng: loc.longitude,
          ));
        }
      }
      return predictions;
    } catch (_) {
      return [];
    }
  }
}
