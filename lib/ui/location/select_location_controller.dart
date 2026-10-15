import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/maps_config.dart';
import '../../models/place_location.dart';
import '../../service/dialog_service.dart';
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
  int _searchSequenceId = 0;
  String? _activeSessionToken;

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

    if (pickupLocation.value == null && pickupTextController.text.isEmpty) {
      fetchCurrentLocationForPickup();
    }
  }

  @override
  void onInit() {
    super.onInit();

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
        dropTextController.text = args['dropAddress'] as String;
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
        _activeSessionToken = _placesService.getSessionToken();
        onSearchChanged(pickupTextController.text);
      }
    });

    dropFocusNode.addListener(() {
      if (dropFocusNode.hasFocus) {
        isPickupFocused.value = false;
        _activeSessionToken = _placesService.getSessionToken();
        onSearchChanged(dropTextController.text);
      }
    });

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

    // Invalidate coordinates if user manually types/edits text
    if (isPickupFocused.value) {
      if (pickupLocation.value != null &&
          pickupLocation.value!.title != cleanQuery &&
          pickupLocation.value!.address != cleanQuery) {
        pickupLocation.value = null;
      }
    } else {
      if (dropLocation.value != null &&
          dropLocation.value!.title != cleanQuery &&
          dropLocation.value!.address != cleanQuery) {
        dropLocation.value = null;
      }
    }

    if (cleanQuery.isEmpty) {
      predictions.clear();
      isSearching.value = false;
      return;
    }

    _activeSessionToken ??= _placesService.getSessionToken();

    isSearching.value = true;
    final currentSeq = ++_searchSequenceId;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final results = await _placesService.searchAutocomplete(
        cleanQuery,
        sessionToken: _activeSessionToken,
      );
      if (currentSeq == _searchSequenceId) {
        predictions.assignAll(results);
        isSearching.value = false;
      }
    });
  }

  Future<void> selectPrediction(PlacePrediction pred) async {
    debugPrint('[SelectLocationController] selectPrediction called for: ${pred.mainText}, isPickupFocused: ${isPickupFocused.value}');
    isSearching.value = true;
    _debounceTimer?.cancel();

    PlaceLocation? loc = await _placesService.getPlaceDetails(
      pred.placeId,
      defaultTitle: pred.mainText,
      prediction: pred,
      sessionToken: _activeSessionToken,
    );
    if (loc == null && pred.fullText.isNotEmpty) {
      loc = await _placesService.geocodeAddress(pred.fullText);
    }
    isSearching.value = false;

    // Reset session token after completion of selection
    _placesService.resetSessionToken();
    _activeSessionToken = null;

    final finalLoc = loc ??
        PlaceLocation(
          title: pred.mainText,
          address: pred.fullText,
          latitude: MapsConfig.defaultLatitude,
          longitude: MapsConfig.defaultLongitude,
          placeId: pred.placeId,
        );

    if (isPickupFocused.value) {
      debugPrint('[SelectLocationController] Setting Pickup location: ${finalLoc.title}');
      setPickup(finalLoc);
      predictions.clear();
      if (dropLocation.value == null && dropTextController.text.isEmpty) {
        dropFocusNode.requestFocus();
      } else {
        pickupFocusNode.unfocus();
      }
    } else {
      debugPrint('[SelectLocationController] Setting Drop location: ${finalLoc.title}');
      setDrop(finalLoc);
      predictions.clear();
      dropFocusNode.unfocus();
    }
  }

  void setPickup(PlaceLocation loc) {
    pickupLocation.value = loc;
    pickupTextController.text = loc.title.isNotEmpty ? loc.title : loc.address;
    debugPrint('[SelectLocationController] pickupLocation set to: ${loc.title} (${loc.latitude}, ${loc.longitude})');
  }

  void setDrop(PlaceLocation loc) {
    dropLocation.value = loc;
    dropTextController.text = loc.title.isNotEmpty ? loc.title : loc.address;
    debugPrint('[SelectLocationController] dropLocation set to: ${loc.title} (${loc.latitude}, ${loc.longitude})');
  }

  void clearPickup() {
    pickupLocation.value = null;
    pickupTextController.clear();
    predictions.clear();
    isPickupFocused.value = true;
    _activeSessionToken = _placesService.getSessionToken();
    pickupFocusNode.requestFocus();
  }

  void clearDrop() {
    dropLocation.value = null;
    dropTextController.clear();
    predictions.clear();
    isPickupFocused.value = false;
    _activeSessionToken = _placesService.getSessionToken();
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
    if (pickupLocation.value != null || pickupTextController.text.isNotEmpty) return;

    isFetchingGps.value = true;
    final cur = await _placesService.getCurrentLocation();
    isFetchingGps.value = false;

    if (cur != null && pickupLocation.value == null && pickupTextController.text.isEmpty) {
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
      DialogService.showToast(
        message: 'Could not fetch your location. Please check location permissions.',
        isWarning: true,
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
