// features/driver/data/repositories/permission_repository_impl.dart

import '../../domain/entities/permission_entity.dart';
import '../../domain/repositories/permission_repository.dart';
import '../../../../core/stores/shared_permission_store.dart';
import './driver_profile_repository_impl.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final _profileRepo = DriverProfileRepositoryImpl();

  @override
  Future<List<PermissionEntity>> getMyPermissions(String idNumber) async {
    // API: GET /api/driver/permissions/$idNumber
    await Future.delayed(const Duration(milliseconds: 400));
    return SharedPermissionStore.getDriverPermissions(idNumber);
  }

  @override
  Future<void> submitPermission({
    required String idNumber,
    required String reason,
    required String requestDate,
    String? duration,
  }) async {
    // API: POST /api/driver/permissions
    // body: { "id_number": idNumber, "reason": reason, "request_date": requestDate, "duration": duration }
    await Future.delayed(const Duration(milliseconds: 800));

    // جلب معلومات السائق لإرفاقها بالإذن (الاسم + رقم السيارة + اسم الخط)
    try {
      final driverInfo = await _profileRepo.getDriverInfo(idNumber);
      final vehicleInfo = await _profileRepo.getVehicleInfo(idNumber);
      final lineInfo = await _profileRepo.getLineInfo(idNumber);

      SharedPermissionStore.submitPermission(
        idNumber: idNumber,
        driverName: driverInfo.fullName,
        vehiclePlate: vehicleInfo.vehicleNumber,
        lineName: lineInfo.lineName,
        reason: reason,
        requestDate: requestDate,
        duration: duration ?? 'يوم واحد',
      );
    } catch (_) {
      SharedPermissionStore.submitPermission(
        idNumber: idNumber,
        driverName: 'سائق',
        vehiclePlate: '-',
        lineName: '-',
        reason: reason,
        requestDate: requestDate,
        duration: duration ?? 'يوم واحد',
      );
    }
  }
}
