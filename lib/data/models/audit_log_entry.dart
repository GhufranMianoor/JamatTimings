class AuditLogEntry {
  final String id;
  final String? masjidId;
  final String? masjidName;
  final String? prayer;
  final String action; // INSERT, UPDATE, DELETE
  final String? oldTime;
  final String? newTime;
  final String? oldLabel;
  final String? newLabel;
  final String? changedBy;
  final String? changedByEmail;
  final DateTime changedAt;

  AuditLogEntry({
    required this.id,
    this.masjidId,
    this.masjidName,
    this.prayer,
    required this.action,
    this.oldTime,
    this.newTime,
    this.oldLabel,
    this.newLabel,
    this.changedBy,
    this.changedByEmail,
    required this.changedAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      masjidId: json['masjid_id'] as String?,
      masjidName: json['masjid_name'] as String?,
      prayer: json['prayer'] as String?,
      action: json['action'] as String,
      oldTime: json['old_time'] as String?,
      newTime: json['new_time'] as String?,
      oldLabel: json['old_label'] as String?,
      newLabel: json['new_label'] as String?,
      changedBy: json['changed_by'] as String?,
      changedByEmail: json['changed_by_email'] as String?,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'masjid_id': masjidId,
      'masjid_name': masjidName,
      'prayer': prayer,
      'action': action,
      'old_time': oldTime,
      'new_time': newTime,
      'old_label': oldLabel,
      'new_label': newLabel,
      'changed_by': changedBy,
      'changed_by_email': changedByEmail,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}
