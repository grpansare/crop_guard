class AgriStore {
  final int? id;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final String? contactNumber;
  final String? ownerName;
  final String storeType;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final int? createdBy;
  final double? distance;

  AgriStore({
    this.id,
    required this.name,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactNumber,
    this.ownerName,
    this.storeType = 'GENERAL',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.distance,
  });

  factory AgriStore.fromJson(Map<String, dynamic> json) {
    return AgriStore(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      contactNumber: json['contactNumber'],
      ownerName: json['ownerName'],
      storeType: json['storeType'] ?? 'GENERAL',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      createdBy: json['createdBy'],
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'contactNumber': contactNumber,
      'ownerName': ownerName,
      'storeType': storeType,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'distance': distance,
    };
  }

  String get storeTypeDisplay {
    switch (storeType) {
      case 'SEEDS':
        return 'Seeds';
      case 'FERTILIZERS':
        return 'Fertilizers';
      case 'PESTICIDES':
        return 'Pesticides';
      case 'EQUIPMENT':
        return 'Equipment';
      case 'GENERAL':
      default:
        return 'General';
    }
  }

  String get distanceDisplay {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }
}

enum StoreType {
  seeds('SEEDS', 'Seeds'),
  fertilizers('FERTILIZERS', 'Fertilizers'),
  pesticides('PESTICIDES', 'Pesticides'),
  equipment('EQUIPMENT', 'Equipment'),
  general('GENERAL', 'General');

  final String value;
  final String display;

  const StoreType(this.value, this.display);
}
