class PlaceLocation {
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;

  const PlaceLocation({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  PlaceLocation copyWith({
    String? title,
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
  }) {
    return PlaceLocation(
      title: title ?? this.title,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
    };
  }

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    return PlaceLocation(
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      placeId: json['placeId'],
    );
  }

  @override
  String toString() => '$title ($address) [$latitude, $longitude]';
}
