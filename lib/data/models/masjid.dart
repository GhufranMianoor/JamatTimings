import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Masjid extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String address;
  @HiveField(3)
  final String city;
  @HiveField(4)
  final String? area;
  @HiveField(5)
  final double latitude;
  @HiveField(6)
  final double longitude;
  @HiveField(7)
  final String? contactPhone;
  @HiveField(8)
  final String? imamName;
  @HiveField(9)
  final String status;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime updatedAt;

  // Client-side transient property
  final double? distanceKm;

  Masjid({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.area,
    required this.latitude,
    required this.longitude,
    this.contactPhone,
    this.imamName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.distanceKm,
  });

  factory Masjid.fromJson(Map<String, dynamic> json, [double? distance]) {
    return Masjid(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      area: json['area'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      contactPhone: json['contact_phone'] as String?,
      imamName: json['imam_name'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      distanceKm: distance ?? (json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'contact_phone': contactPhone,
      'imam_name': imamName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Masjid copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
    String? contactPhone,
    String? imamName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distanceKm,
  }) {
    return Masjid(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPhone: contactPhone ?? this.contactPhone,
      imamName: imamName ?? this.imamName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

class MasjidAdapter extends TypeAdapter<Masjid> {
  @override
  final int typeId = 0;

  @override
  Masjid read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Masjid(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      city: fields[3] as String,
      area: fields[4] as String?,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      contactPhone: fields[7] as String?,
      imamName: fields[8] as String?,
      status: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Masjid obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.area)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.contactPhone)
      ..writeByte(8)
      ..write(obj.imamName)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }
}
