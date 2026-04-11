// features/driver/domain/entities/permission_entity.dart
class PermissionEntity {
  final String id;
  final String reason; // ← نص حر يكتبه السائق (تحول من dropdown)
  final String requestDate;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;

  const PermissionEntity({
    required this.id,
    required this.reason,
    required this.requestDate,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory PermissionEntity.fromJson(Map<String, dynamic> json) {
    return PermissionEntity(
      id: json['id'] ?? '',
      reason: json['reason'] ?? '',
      requestDate: json['request_date'] ?? '',
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
