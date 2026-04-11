class PermissionEntity {
  final String  id;
  final String  type;
  final String? reason;           // ← سبب الإذن (يكتبه السائق عند "أخرى")
  final String  requestDate;
  final String  duration;
  final String  status;
  final String? vehiclePlate;
  final String? rejectionReason;  // ← أضف: سبب الرفض (يكتبه المشرف/الأدمن)
  final DateTime createdAt;

  const PermissionEntity({
    required this.id,
    required this.type,
    this.reason,
    required this.requestDate,
    required this.duration,
    required this.status,
    this.vehiclePlate,
    this.rejectionReason,          // ← اختياري
    required this.createdAt,
  });

  factory PermissionEntity.fromJson(Map<String, dynamic> json) {
    return PermissionEntity(
      id:              json['id']               ?? '',
      type:            json['type']             ?? '',
      reason:          json['reason'],
      requestDate:     json['request_date']     ?? '',
      duration:        json['duration']         ?? '',
      status:          json['status']           ?? 'pending',
      vehiclePlate:    json['vehicle_plate'],
      rejectionReason: json['rejection_reason'], // ← من الـ API (null إذا لم يُرفض)
      createdAt:       DateTime.parse(json['created_at']),
    );
  }
}
