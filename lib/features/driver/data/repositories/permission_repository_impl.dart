import '../../domain/entities/permission_entity.dart';
import '../../domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  // ← قائمة داخلية تحفظ الطلبات طول عمر التطبيق
  static final List<PermissionEntity> _mockPermissions = [
    PermissionEntity(
      id: '1',
      type: 'maintenance',
      requestDate: '2026-02-15',
      duration: '30 دقيقة',
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PermissionEntity(
      id: '2',
      type: 'parcel',
      requestDate: '2026-02-18',
      duration: '15 دقيقة',
      status: 'rejected',
      rejectionReason:
          'الوقت المحدد غير متاح، يرجى إعادة الطلب لاحقاً', // ← Mock لسبب الرفض
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PermissionEntity(
      id: '3',
      type: 'other',
      reason: 'شراء مستلزمات شخصية',
      requestDate: '2026-03-18',
      duration: '1 ساعة',
      status: 'pending',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<PermissionEntity>> getMyPermissions(String idNumber) async {
    // ← عند ربط الـ API استبدل بـ:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/permissions/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // final List data = jsonDecode(response.body);
    // return data.map((e) => PermissionEntity.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 500));

    // ← يرجع نسخة من القائمة مرتبة من الأحدث للأقدم
    final sorted = List<PermissionEntity>.from(_mockPermissions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<void> submitPermission({
    required String idNumber,
    required String type,
    String? reason,
    required String requestDate,
    required String duration,
  }) async {
    // ← عند ربط الـ API استبدل بـ:
    // await http.post(
    //   Uri.parse('$baseUrl/api/permissions/submit'),
    //   headers: {'Authorization': 'Bearer $token'},
    //   body: {
    //     'id_number':    idNumber,
    //     'type':         type,
    //     'reason':       reason ?? '',
    //     'request_date': requestDate,
    //     'duration':     duration,
    //   },
    // );

    await Future.delayed(const Duration(seconds: 1));

    // ← أضف الطلب الجديد للقائمة الداخلية
    final newPermission = PermissionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      reason: reason,
      requestDate: requestDate,
      duration: duration,
      status: 'pending', // ← دائماً pending عند الإرسال
      createdAt: DateTime.now(),
    );

    _mockPermissions.add(newPermission);
  }
}
