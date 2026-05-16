// features/supervisor/domain/entities/external_request_entity.dart
//
// ── متوافق مع OrderEntity في تطبيق Passengers ────────────────────────────────
// الحقول مطابقة لما يرسله تطبيق Passengers للـ Backend

enum ExternalRequestType { passengers, parcel }

class ExternalRequestEntity {
  final String id;

  /// اسم الراكب — من: full_name في Passengers
  final String requesterName;

  /// رقم هاتف للتواصل — من: contact_phone في Passengers
  final String requesterPhone;

  /// نوع الطلب: passengers | parcel
  final ExternalRequestType type;

  /// موقع الانطلاق (GPS أو يدوي) — من: location في Passengers
  final String location;

  /// الوجهة المطلوبة — من: destination في Passengers
  final String destination;

  /// عدد الركاب — من: passengers_count في Passengers (إذا type == passengers)
  final int? passengersCount;

  /// اسم الطرد — من: parcel_name في Passengers (إذا type == parcel)
  final String? parcelName;

  /// تفاصيل الطرد — من: parcel_details في Passengers (إذا type == parcel)
  final String? parcelDetails;

  /// الحالة: pending | approved | rejected
  final String status;

  final DateTime createdAt;

  const ExternalRequestEntity({
    required this.id,
    required this.requesterName,
    required this.requesterPhone,
    required this.type,
    required this.location,
    required this.destination,
    this.passengersCount,
    this.parcelName,
    this.parcelDetails,
    required this.status,
    required this.createdAt,
  });

  ExternalRequestEntity copyWith({String? status}) {
    return ExternalRequestEntity(
      id: id,
      requesterName: requesterName,
      requesterPhone: requesterPhone,
      type: type,
      location: location,
      destination: destination,
      passengersCount: passengersCount,
      parcelName: parcelName,
      parcelDetails: parcelDetails,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  // ── من JSON (استجابة API) ─────────────────────────────────────────────────
  // مطابق لـ OrderEntity.toJson() في Passengers
  factory ExternalRequestEntity.fromJson(Map<String, dynamic> json) {
    return ExternalRequestEntity(
      id: json['id'] ?? '',
      requesterName: json['full_name'] ?? json['requester_name'] ?? '',
      requesterPhone: json['contact_phone'] ?? json['requester_phone'] ?? '',
      type: json['type'] == 'parcel'
          ? ExternalRequestType.parcel
          : ExternalRequestType.passengers,
      location: json['location'] ?? '',
      destination: json['destination'] ?? '',
      passengersCount: json['passengers_count'],
      parcelName: json['parcel_name'],
      parcelDetails: json['parcel_details'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
