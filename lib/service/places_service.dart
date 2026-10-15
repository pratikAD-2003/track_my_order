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

  /// Search places with STRICT LOCAL RESTRICTION (Nearby current city/state):
  /// 1. Google Places Text Search (New) with strict `locationRestriction` (50km radius circle)
  /// 2. Google Places Autocomplete (New) with strict `locationRestriction`
  /// 3. OpenStreetMap Nominatim with strict `viewbox` & `bounded=1`
  /// 4. Local Geocoding Package fallback
  Future<List<PlacePrediction>> searchAutocomplete(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    // Get current GPS position for strict local restriction
    double centerLat = MapsConfig.defaultLatitude;
    double centerLng = MapsConfig.defaultLongitude;
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        centerLat = pos.latitude;
        centerLng = pos.longitude;
      }
    } catch (_) {}

    // 1. Try Google Places Text Search API (New) - STRICT `locationRestriction` (50km circle)
    try {
      final textSearchUrl = Uri.parse('https://places.googleapis.com/v1/places:searchText');
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
              'locationRestriction': {
                'circle': {
                  'center': {
                    'latitude': centerLat,
                    'longitude': centerLng,
                  },
                  'radius': 50000.0, // 50km strict radius around current user location
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 4));

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
              secondaryText = parts.skip(1).join(', ').trim();
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
      debugPrint('[PlacesService] Google Places Text Search (New) warning: $e');
    }

    // 2. Try Google Places Autocomplete API (New) - STRICT `locationRestriction`
    try {
      final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': MapsConfig.apiKey,
            },
            body: jsonEncode({
              'input': cleanQuery,
              'includedRegionCodes': ['in'],
              'locationRestriction': {
                'circle': {
                  'center': {
                    'latitude': centerLat,
                    'longitude': centerLng,
                  },
                  'radius': 50000.0,
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['suggestions'] as List<dynamic>? ?? [];

        final results = <PlacePrediction>[];
        for (final item in suggestions) {
          final pred = item['placePrediction'];
          if (pred != null) {
            final placeId = pred['placeId'] ?? '';
            final structured = pred['structuredFormat'];
            final main = structured?['mainText']?['text'] ?? pred['text']?['text'] ?? '';
            final secondary = structured?['secondaryText']?['text'] ?? '';
            final full = pred['text']?['text'] ?? '$main, $secondary';

            results.add(PlacePrediction(
              placeId: placeId,
              mainText: main,
              secondaryText: secondary,
              fullText: full,
            ));
          }
        }
        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      debugPrint('[PlacesService] Google Places (New) autocomplete warning: $e');
    }

    // 3. Try OpenStreetMap Nominatim with strict viewbox & bounded=1 (local area only)
    try {
      // Create bounding box approx 0.5 degrees around centerLat, centerLng (~50km)
      final minLon = centerLng - 0.45;
      final maxLon = centerLng + 0.45;
      final minLat = centerLat - 0.45;
      final maxLat = centerLat + 0.45;

      final osmUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(cleanQuery)}&format=json&addressdetails=1&countrycodes=in&viewbox=$minLon,$minLat,$maxLon,$maxLat&bounded=1&limit=6',
      );
      final response = await http.get(
        osmUrl,
        headers: {
          'User-Agent': 'TrackMyOrderApp/1.0 (com.pratik.track_my_order)',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final results = <PlacePrediction>[];
          for (final item in data) {
            if (item is Map) {
              final displayName = item['display_name']?.toString() ?? '';
              final name = item['name']?.toString() ?? '';
              final address = item['address'];
              final lat = double.tryParse(item['lat']?.toString() ?? '');
              final lon = double.tryParse(item['lon']?.toString() ?? '');

              String mainText = name.isNotEmpty ? name : displayName.split(',').first;
              String secondaryText = '';
              if (address is Map) {
                final parts = [
                  if (address['suburb'] != null) address['suburb'],
                  if (address['city'] != null) address['city'],
                  if (address['town'] != null) address['town'],
                  if (address['state'] != null) address['state'],
                ];
                secondaryText = parts.take(2).join(', ');
              }
              if (secondaryText.isEmpty && displayName.contains(',')) {
                secondaryText = displayName.substring(displayName.indexOf(',') + 1).trim();
              }

              results.add(PlacePrediction(
                placeId: 'osm_${item['place_id']}',
                mainText: mainText,
                secondaryText: secondaryText,
                fullText: displayName,
                lat: lat,
                lng: lon,
              ));
            }
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (e) {
      debugPrint('[PlacesService] OpenStreetMap Nominatim warning: $e');
    }

    // 4. Fallback: Use geocoding Flutter package
    return _fallbackGeocodingSearch(cleanQuery);
  }

  /// Fetches place coordinates and formatted address by Place ID via Google Places API (New) or OpenStreetMap.
  Future<PlaceLocation?> getPlaceDetails(String placeId, {String? defaultTitle, PlacePrediction? prediction}) async {
    // Check prediction lat/lng first
    if (prediction != null && prediction.lat != null && prediction.lng != null) {
      return PlaceLocation(
        title: prediction.mainText,
        address: prediction.fullText,
        latitude: prediction.lat!,
        longitude: prediction.lng!,
        placeId: placeId,
      );
    }

    // 1. If generated from fallback geocoding search
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

    // 2. Google Places API (New) details
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');
    try {
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
        final lat = (loc?['latitude'] as num?)?.toDouble() ?? MapsConfig.defaultLatitude;
        final lng = (loc?['longitude'] as num?)?.toDouble() ?? MapsConfig.defaultLongitude;

        return PlaceLocation(
          title: title,
          address: formattedAddress,
          latitude: lat,
          longitude: lng,
          placeId: placeId,
        );
      }
    } catch (e) {
      debugPrint('[PlacesService] Place details exception: $e');
    }

    // 3. Fallback: Geocode title or defaultTitle
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
  Future<PlaceLocation> reverseGeocode(double lat, double lng) async {
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

    return PlaceLocation(
      title: 'Current Location',
      address: MapsConfig.defaultCity,
      latitude: lat,
      longitude: lng,
    );
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
        return await reverseGeocode(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
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
      return await reverseGeocode(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
    }
  }

  /// Fallback search using Flutter's native `geocoding` package
  Future<List<PlacePrediction>> _fallbackGeocodingSearch(String query) async {
    try {
      final locations = await _geocoding.locationFromAddress(query).timeout(const Duration(seconds: 4));
      final predictions = <PlacePrediction>[];

      for (int i = 0; i < locations.length && i < 5; i++) {
        final loc = locations[i];
        final marks = await _geocoding.placemarkFromCoordinates(loc.latitude, loc.longitude);
        if (marks.isNotEmpty) {
          final p = marks.first;
          final main = p.name ?? p.subLocality ?? query;
          final sec = '${p.locality ?? ''}, ${p.administrativeArea ?? ''}'.trim();
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
