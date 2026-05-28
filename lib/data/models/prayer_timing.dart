import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class PrayerTiming extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String masjidId;
  @HiveField(2)
  final String prayer; // fajr, dhuhr, asr, maghrib, isha, jumuah, taraweeh, eid
  @HiveField(3)
  final String jamatTime; // HH:mm format
  @HiveField(4)
  final String? label;
  @HiveField(5)
  final bool isRamadan;
  @HiveField(6)
  final DateTime? validFrom;
  @HiveField(7)
  final DateTime? validUntil;
  @HiveField(8)
  final String? updatedBy;
  @HiveField(9)
  final DateTime updatedAt;

  PrayerTiming({
    required this.id,
    required this.masjidId,
    required this.prayer,
    required this.jamatTime,
    this.label,
    required this.isRamadan,
    this.validFrom,
    this.validUntil,
    this.updatedBy,
    required this.updatedAt,
  });

  factory PrayerTiming.fromJson(Map<String, dynamic> json) {
    return PrayerTiming(
      id: json['id'] as String,
      masjidId: json['masjid_id'] as String,
      prayer: json['prayer'] as String,
      jamatTime: json['jamat_time'] as String,
      label: json['label'] as String?,
      isRamadan: json['is_ramadan'] as bool? ?? false,
      validFrom: json['valid_from'] != null ? DateTime.parse(json['valid_from'] as String) : null,
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until'] as String) : null,
      updatedBy: json['updated_by'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'masjid_id': masjidId,
      'prayer': prayer,
      'jamat_time': jamatTime,
      'label': label,
      'is_ramadan': isRamadan,
      'valid_from': validFrom?.toIso8601String().substring(0, 10),
      'valid_until': validUntil?.toIso8601String().substring(0, 10),
      'updated_by': updatedBy,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PrayerTiming copyWith({
    String? id,
    String? masjidId,
    String? prayer,
    String? jamatTime,
    String? label,
    bool? isRamadan,
    DateTime? validFrom,
    DateTime? validUntil,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return PrayerTiming(
      id: id ?? this.id,
      masjidId: masjidId ?? this.masjidId,
      prayer: prayer ?? this.prayer,
      jamatTime: jamatTime ?? this.jamatTime,
      label: label ?? this.label,
      isRamadan: isRamadan ?? this.isRamadan,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime get jamatDateTime {
    final now = DateTime.now();
    final parts = jamatTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  bool get isCurrentlyValid {
    final today = DateTime.now();
    if (validFrom != null && today.isBefore(validFrom!)) return false;
    if (validUntil != null && today.isAfter(validUntil!)) return false;
    return true;
  }
}

class PrayerTimingAdapter extends TypeAdapter<PrayerTiming> {
  @override
  final int typeId = 1;

  @override
  PrayerTiming read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTiming(
      id: fields[0] as String,
      masjidId: fields[1] as String,
      prayer: fields[2] as String,
      jamatTime: fields[3] as String,
      label: fields[4] as String?,
      isRamadan: fields[5] as bool,
      validFrom: fields[6] as DateTime?,
      validUntil: fields[7] as DateTime?,
      updatedBy: fields[8] as String?,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTiming obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.masjidId)
      ..writeByte(2)
      ..write(obj.prayer)
      ..writeByte(3)
      ..write(obj.jamatTime)
      ..writeByte(4)
      ..write(obj.label)
      ..writeByte(5)
      ..write(obj.isRamadan)
      ..writeByte(6)
      ..write(obj.validFrom)
      ..writeByte(7)
      ..write(obj.validUntil)
      ..writeByte(8)
      ..write(obj.updatedBy)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }
}
