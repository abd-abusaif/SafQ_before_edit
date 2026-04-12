// features/driver/data/repositories/permission_repository_impl.dart

import '../../domain/entities/permission_entity.dart';
import '../../domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  static final List<PermissionEntity> _mockPermissions = [
    PermissionEntity(
      id: '1',
      reason: 'موعد طبي طارئ في مستشفى الخليل الحكومي',
      requestDate: '2026-02-15',
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PermissionEntity(
      id: '2',
      reason: 'إجراءات تجديد رخصة القيادة في مديرية المرور',
      requestDate: '2026-02-18',
      status: 'rejected',
      rejectionReason: 'الوقت المحدد غير متاح، يرجى إعادة الطلب لاحقاً',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PermissionEntity(
      id: '3',
      reason: 'مراسم عزاء عائلية',
      requestDate: '2026-03-18',
      status: 'pending',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<PermissionEntity>> getMyPermissions(String idNumber) async {
    // API: GET /api/driver/permissions/$idNumber
    await Future.delayed(const Duration(milliseconds: 500));
    final sorted = List<PermissionEntity>.from(_mockPermissions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<void> submitPermission({
    required String idNumber,
    required String reason,
    required String requestDate,
  }) async {
    // API: POST /api/driver/permissions
    // body: { "id_number": idNumber, "reason": reason, "request_date": requestDate }
    await Future.delayed(const Duration(seconds: 1));
    _mockPermissions.add(
      PermissionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reason: reason,
        requestDate: requestDate,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );
  }
}
