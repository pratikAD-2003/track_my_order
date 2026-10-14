class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String itemDescription;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final String status; // 'pending' | 'accepted' | 'picked_up' | 'in_transit' | 'delivered' | 'cancelled'
  final String? partnerId;
  final String? partnerName;
  final String? partnerPhone;
  final String? partnerVehicle;
  final String otp; // 4-digit code generated for customer
  final int estimatedMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.itemDescription,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.status,
    this.partnerId,
    this.partnerName,
    this.partnerPhone,
    this.partnerVehicle,
    required this.otp,
    this.estimatedMinutes = 15,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isPickedUp => status == 'picked_up';
  bool get isInTransit => status == 'in_transit';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive =>
      status == 'pending' ||
      status == 'accepted' ||
      status == 'picked_up' ||
      status == 'in_transit';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Searching Rider';
      case 'accepted':
        return 'Rider Assigned';
      case 'picked_up':
        return 'Picked Up';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  static double _parseDouble(dynamic val, double fallback) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  static int _parseInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }

  static DateTime _parseDateTime(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is num) return DateTime.fromMillisecondsSinceEpoch(val.toInt());
    if (val is String) {
      final asInt = int.tryParse(val);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
      return DateTime.tryParse(val) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'itemDescription': itemDescription,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropAddress': dropAddress,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'status': status,
      'otp': otp,
      'estimatedMinutes': estimatedMinutes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
    if (partnerId != null && partnerId!.isNotEmpty) map['partnerId'] = partnerId;
    if (partnerName != null && partnerName!.isNotEmpty) map['partnerName'] = partnerName;
    if (partnerPhone != null && partnerPhone!.isNotEmpty) map['partnerPhone'] = partnerPhone;
    if (partnerVehicle != null && partnerVehicle!.isNotEmpty) map['partnerVehicle'] = partnerVehicle;
    return map;
  }

  factory OrderModel.fromMap(Map<dynamic, dynamic> map, String keyId) {
    final prefix = keyId.length >= 4 ? keyId.substring(0, 4).toUpperCase() : keyId.toUpperCase();
    return OrderModel(
      id: keyId,
      orderNumber: map['orderNumber']?.toString() ?? '#ORD-$prefix',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? 'Customer',
      customerPhone: map['customerPhone']?.toString() ?? '',
      itemDescription: map['itemDescription']?.toString() ?? 'Package Delivery',
      pickupAddress: map['pickupAddress']?.toString() ?? 'Pickup Point',
      pickupLat: _parseDouble(map['pickupLat'], 19.0760),
      pickupLng: _parseDouble(map['pickupLng'], 72.8777),
      dropAddress: map['dropAddress']?.toString() ?? 'Drop Point',
      dropLat: _parseDouble(map['dropLat'], 19.0896),
      dropLng: _parseDouble(map['dropLng'], 72.8656),
      status: map['status']?.toString() ?? 'pending',
      partnerId: map['partnerId']?.toString(),
      partnerName: map['partnerName']?.toString(),
      partnerPhone: map['partnerPhone']?.toString(),
      partnerVehicle: map['partnerVehicle']?.toString(),
      otp: map['otp']?.toString() ?? '1234',
      estimatedMinutes: _parseInt(map['estimatedMinutes'], 15),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? itemDescription,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? dropAddress,
    double? dropLat,
    double? dropLng,
    String? status,
    String? partnerId,
    String? partnerName,
    String? partnerPhone,
    String? partnerVehicle,
    String? otp,
    int? estimatedMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      itemDescription: itemDescription ?? this.itemDescription,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropAddress: dropAddress ?? this.dropAddress,
      dropLat: dropLat ?? this.dropLat,
      dropLng: dropLng ?? this.dropLng,
      status: status ?? this.status,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerPhone: partnerPhone ?? this.partnerPhone,
      partnerVehicle: partnerVehicle ?? this.partnerVehicle,
      otp: otp ?? this.otp,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
