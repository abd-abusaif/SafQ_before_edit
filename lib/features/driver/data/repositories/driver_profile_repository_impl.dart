// features/driver/data/repositories/driver_profile_repository_impl.dart

import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_profile_repository.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  @override
  Future<DriverInfoEntity> getDriverInfo(String idNumber) async {
    // API: GET /api/driver/info/$idNumber
    await Future.delayed(const Duration(milliseconds: 500));
    return const DriverInfoEntity(
      fullName: 'عبدالرحمن محمد أحمد أبو سيف',
      firstName: 'أبو سيف',
      idNumber: '409581394',
      phone1: '0599123456',
      phone2: '0591987654',
      licenseNumber: 'DL-123456',
      licenseGrade: 'درجة أولى',
      licenseExpiry: '2025-04-20',
      medicalExpiry: '2025-12-01',
    );
  }

  @override
  Future<LineInfoEntity> getLineInfo(String idNumber) async {
    // API: GET /api/driver/line/$idNumber
    await Future.delayed(const Duration(milliseconds: 500));
    return const LineInfoEntity(
      lineNumber: '55',
      lineName: 'الخليل – دورا',
      lineFrom: 'الخليل',
      lineTo: 'دورا',
      route: 'الخليل ← بيت كاحل ← دورا',
      passengerFare: '4.00 ₪',
    );
  }

  @override
  Future<OwnerInfoEntity> getOwnerInfo(String idNumber) async {
    // API: GET /api/driver/owner/$idNumber
    await Future.delayed(const Duration(milliseconds: 300));
    return const OwnerInfoEntity(
      ownerName: 'محمد أحمد أبو سيف',
      ownerId: '123456789',
      ownerPhone: '0592345678',
    );
  }

  @override
  Future<VehicleInfoEntity> getVehicleInfo(String idNumber) async {
    // API: GET /api/driver/vehicle/$idNumber
    await Future.delayed(const Duration(milliseconds: 500));
    return const VehicleInfoEntity(
      vehicleNumber: 'ر ح ن 123',
      vehicleCode: 'VC-409581',
      chassisNumber: 'WVWZZZ1KZ9M012345',
      company: 'فولكسفاغن',
      model: 'كرافتر',
      productionYear: '2019',
      seats: '14',
      operationExpiry: '2025-04-22',
      vehicleLicExpiry: '2026-03-20',
      insuranceExpiry: '2026-09-10',
      loadingAllowed: true,
    );
  }
}
