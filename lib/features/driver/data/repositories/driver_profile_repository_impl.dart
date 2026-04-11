import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_profile_repository.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  @override
  Future<DriverInfoEntity> getDriverInfo(String idNumber) async {
    // ← عند ربط الـ API استبدل بـ:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/driver/profile/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // return DriverInfoEntity.fromJson(jsonDecode(response.body));

    await Future.delayed(const Duration(milliseconds: 500));
    return const DriverInfoEntity(
      fullName: 'عبدالرحمن محمد أحمد أبو سيف',
      idNumber: '409581394',
      phone1: '0599123456',
      phone2: '0591987654', // ← Mock رقم 2
      licenseNumber: 'DL-123456',
      licenseGrade: 'درجة أولى', // ← Mock درجة الرخصة
      licenseExpiry: '2026-08-15',
      medicalExpiry: '2025-12-01',
    );
  }

  @override
  Future<LineInfoEntity> getLineInfo(String idNumber) async {
    // ← عند ربط الـ API استبدل بـ:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/driver/line/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // return LineInfoEntity.fromJson(jsonDecode(response.body));

    await Future.delayed(const Duration(milliseconds: 500));
    return const LineInfoEntity(
      lineNumber: '5',
      lineName: 'بيت لحم - الخليل',
      passengerFare: '5.50 ₪',
    );
  }

  @override
  Future<VehicleInfoEntity> getVehicleInfo(String idNumber) async {
    // ← عند ربط الـ API استبدل بـ:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/vehicle/profile/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // return VehicleInfoEntity.fromJson(jsonDecode(response.body));
    // ← ملاحظة: chassis_number يأتي من الأدمن، قد يكون null

    await Future.delayed(const Duration(milliseconds: 500));
    return const VehicleInfoEntity(
      vehicleNumber: 'أ ب ج 1234',
      vehicleCode: 'VC-409581',
      model: 'تويوتا هايس 2020',
      driverType: 'سائق رئيسي',
      seats: '14',
      operationExpiry: '2025-11-30',
      vehicleLicExpiry: '2026-03-20',
      insuranceExpiry: '2025-09-10',
      chassisNumber: 'CHS-1234567890', // ← يضيفه الأدمن، null إذا لم يُضف
    );
  }
}
