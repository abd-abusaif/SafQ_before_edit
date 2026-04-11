import '../entities/permission_entity.dart';

abstract class PermissionRepository {
  Future<List<PermissionEntity>> getMyPermissions(String idNumber);
  Future<void> submitPermission({
    required String idNumber,
    required String type,
    String? reason,
    required String requestDate,
    required String duration,
  });
}
