import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/maps_config.dart';
import '../../models/place_location.dart';
import '../../service/places_service.dart';
import 'map_location_picker_screen.dart';

class SelectLocationController extends GetxController {
  final PlacesService _placesService = PlacesService();

  final pickupTextController = TextEditingController();
  final dropTextController = TextEditingController();

  final pickupFocusNode = FocusNode();
  final dropFocusNode = FocusNode();

  final pickupLocation = Rx<PlaceLocation?>(null);
  final dropLocation = Rx<PlaceLocation?>(null);

  final isPickupFocused = true.obs;
  final isSearching = false.obs;
  final isFetchingGps = false.obs;
  final predictions = <PlacePrediction>[].obs;

  Timer? _debounceTimer;

  void initFromParams({
    String? initialPickup,
    String? initialDrop,
    bool focusDrop = false,
  }) {
    if (initialPickup != null &&
        initialPickup.isNotEmpty &&
        initialPickup != 'Fetching current location...') {
      pickupTextController.text = initialPickup;
    }
    if (initialDrop != null && initialDrop.isNotEmpty) {
      dropTextController.text = initialDrop;
    }
    if (focusDrop) {
      isPickupFocused.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!dropFocusNode.hasFocus) {
          dropFocusNode.requestFocus();
        }
      });
    }

    // Initially auto-fetch device current location for pickup if empty
    if (pickupLocation.value == null && pickupTextController.text.isEmpty) {
      fetchCurrentLocationForPickup();
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Check if initial locations were passed in arguments
    final args = Get.arguments;
    if (args is Map) {
      if (args['pickup'] is PlaceLocation) {
        setPickup(args['pickup'] as PlaceLocation);
      } else if (args['pickupAddress'] is String) {
        final p = args['pickupAddress'] as String;
        if (p.isNotEmpty && p != 'Fetching current location...') {
          pickupTextController.text = p;
        }
      }

      if (args['drop'] is PlaceLocation) {
        setDrop(args['drop'] as PlaceLocation);
      } else if (args['dropAddress'] is String) {
        dropTextController.text = args['dropAddress'];
      }

      if (args['focusDrop'] == true) {
        isPickupFocused.value = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          dropFocusNode.requestFocus();
        });
      }
    }

    pickupFocusNode.addListener(() {
      if (pickupFocusNode.hasFocus) {
        isPickupFocused.value = true;
        onSearchChanged(pickupTextController.text);
      }
    });

    dropFocusNode.addListener(() {
      if (dropFocusNode.hasFocus) {
        isPickupFocused.value = false;
        onSearchChanged(dropTextController.text);
      }
    });

    // Auto-fetch current location for pickup if empty
    if (pickupLocation.value == null && pickupTextController.text.isEmpty) {
      fetchCurrentLocationForPickup();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    pickupTextController.dispose();
    dropTextController.dispose();
    pickupFocusNode.dispose();
    dropFocusNode.dispose();
    super.onClose();
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      predictions.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      final results = await _placesService.searchAutocomplete(cleanQuery);
      predictions.assignAll(results);
      isSearching.value = false;
    });
  }

  Future<void> selectPrediction(PlacePrediction pred) async {
    isSearching.value = true;
    PlaceLocation? loc = await _placesService.getPlaceDetails(
      pred.placeId,
      defaultTitle: pred.mainText,
      prediction: pred,
    );
    if (loc == null && pred.fullText.isNotEmpty) {
      loc = await _placesService.geocodeAddress(pred.fullText);
    }
    isSearching.value = false;

    final finalLoc = loc ??
        PlaceLocation(
          title: pred.mainText,
          address: pred.fullText,
          latitude: MapsConfig.defaultLatitude,
          longitude: MapsConfig.defaultLongitude,
          placeId: pred.placeId,
        );

    if (isPickupFocused.value) {
      setPickup(finalLoc);
      predictions.clear();
      if (dropLocation.value == null && dropTextController.text.isEmpty) {
        dropFocusNode.requestFocus();
      } else {
        pickupFocusNode.unfocus();
      }
    } else {
      setDrop(finalLoc);
      predictions.clear();
      dropFocusNode.unfocus();
    }
  }

  void setPickup(PlaceLocation loc) {
    pickupLocation.value = loc;
    pickupTextController.text = loc.title.isNotEmpty ? loc.title : loc.address;
  }

  void setDrop(PlaceLocation loc) {
    dropLocation.value = loc;
    dropTextController.text = loc.title.isNotEmpty ? loc.title : loc.address;
  }

  void clearPickup() {
    pickupLocation.value = null;
    pickupTextController.clear();
    predictions.clear();
    pickupFocusNode.requestFocus();
  }

  void clearDrop() {
    dropLocation.value = null;
    dropTextController.clear();
    predictions.clear();
    dropFocusNode.requestFocus();
  }

  void swapLocations() {
    final tempLoc = pickupLocation.value;
    final tempText = pickupTextController.text;

    pickupLocation.value = dropLocation.value;
    pickupTextController.text = dropTextController.text;

    dropLocation.value = tempLoc;
    dropTextController.text = tempText;
  }

  Future<void> fetchCurrentLocationForPickup() async {
    isFetchingGps.value = true;
    final cur = await _placesService.getCurrentLocation();
    isFetchingGps.value = false;

    if (cur != null) {
      setPickup(cur);
    }
  }

  Future<void> useCurrentLocation() async {
    isFetchingGps.value = true;
    final cur = await _placesService.getCurrentLocation();
    isFetchingGps.value = false;

    if (cur != null) {
      if (isPickupFocused.value) {
        setPickup(cur);
        if (dropLocation.value == null) {
          dropFocusNode.requestFocus();
        }
      } else {
        setDrop(cur);
      }
      predictions.clear();
    } else {
      Get.snackbar(
        'GPS Unavailable',
        'Could not fetch your location. Please check location permissions.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openMapPicker({required bool isPickup}) async {
    LatLng? initialPos;

    final loc = isPickup ? pickupLocation.value : dropLocation.value;
    if (loc != null && loc.latitude != 0 && loc.longitude != 0) {
      initialPos = LatLng(loc.latitude, loc.longitude);
    } else {
      final text = isPickup ? pickupTextController.text : dropTextController.text;
      if (text.trim().isNotEmpty) {
        final geocoded = await _placesService.geocodeAddress(text);
        if (geocoded != null) {
          initialPos = LatLng(geocoded.latitude, geocoded.longitude);
        }
      }
    }

    final result = await Get.to<PlaceLocation?>(
      () => MapLocationPickerScreen(
        title: isPickup ? 'Set Pickup on Map' : 'Set Drop on Map',
        isPickup: isPickup,
        initialPosition: initialPos,
      ),
    );

    if (result != null) {
      if (isPickup) {
        setPickup(result);
        if (dropLocation.value == null) {
          dropFocusNode.requestFocus();
        }
      } else {
        setDrop(result);
      }
      predictions.clear();
    }
  }

  bool get canConfirm =>
      pickupLocation.value != null && dropLocation.value != null;

  void confirmLocations() {
    if (!canConfirm) return;

    Get.back(result: {
      'pickup': pickupLocation.value!,
      'drop': dropLocation.value!,
    });
  }
}
