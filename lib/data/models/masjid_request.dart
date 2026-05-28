class MasjidRequest {
  final String id;
  final String masjidName;
  final String address;
  final String city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final String? contactPhone;
  final String? imamName;
  final List<dynamic>? initialTimings;
  final String adminEmail;
  final String? note;
  final String status; // pending, approved, rejected, info_requested
  final String? rejectionReason;
  final String? submittedBy;
  final String? reviewedBy;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  MasjidRequest({
    required this.id,
    required this.masjidName,
    required this.address,
    required this.city,
    this.area,
    this.latitude,
    this.longitude,
    this.contactPhone,
    this.imamName,
    this.initialTimings,
    required this.adminEmail,
    this.note,
    required this.status,
    this.rejectionReason,
    this.submittedBy,
    this.reviewedBy,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory MasjidRequest.fromJson(Map<String, dynamic> json) {
    return MasjidRequest(
      id: json['id'] as String,
      masjidName: json['masjid_name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      area: json['area'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      contactPhone: json['contact_phone'] as String?,
      imamName: json['imam_name'] as String?,
      initialTimings: json['initial_timings'] as List<dynamic>?,
      adminEmail: json['admin_email'] as String,
      note: json['note'] as String?,
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      submittedBy: json['submitted_by'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'masjid_name': masjidName,
      'address': address,
      'city': city,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'contact_phone': contactPhone,
      'imam_name': imamName,
      'initial_timings': initialTimings,
      'admin_email': adminEmail,
      'note': note,
      'status': status,
      'rejection_reason': rejectionReason,
      'submitted_by': submittedBy,
      'reviewed_by': reviewedBy,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  MasjidRequest copyWith({
    String? id,
    String? masjidName,
    String? address,
    String? city,
    String? area,
    double? latitude,
    double? longitude,
    String? contactPhone,
    String? imamName,
    List<dynamic>? initialTimings,
    String? adminEmail,
    String? note,
    String? status,
    String? rejectionReason,
    String? submittedBy,
    String? reviewedBy,
    DateTime? submittedAt,
    DateTime? reviewedAt,
  }) {
    return MasjidRequest(
      id: id ?? this.id,
      masjidName: masjidName ?? this.masjidName,
      address: address ?? this.address,
      city: city ?? this.city,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPhone: contactPhone ?? this.contactPhone,
      imamName: imamName ?? this.imamName,
      initialTimings: initialTimings ?? this.initialTimings,
      adminEmail: adminEmail ?? this.adminEmail,
      note: note ?? this.note,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedBy: submittedBy ?? this.submittedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
