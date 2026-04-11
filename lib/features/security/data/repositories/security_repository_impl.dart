import '../../domain/entities/security_vehicle_entity.dart';
import '../../domain/repositories/security_repository.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  @override
  Future<List<SecurityVehicleEntity>> getVehicles(String idNumber) async {
    // ← عند ربط الـ API استبدل بـ:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/security/vehicles/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // final List data = jsonDecode(response.body);
    // return data.map((e) => SecurityVehicleEntity.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 500));
    return [
      SecurityVehicleEntity(
        id: '1',
        driverName: 'أحمد محمد',
        vehiclePlate: 'أ ب ج 1234',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:15 AM',
        queuePosition: 1,
        isApproved: true,
        entryDateTime: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
      SecurityVehicleEntity(
        id: '2',
        driverName: 'خالد إبراهيم',
        vehiclePlate: 'د هـ و 5678',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:20 AM',
        queuePosition: 2,
        isApproved: false,
        rejectionReason: 'رخصة السيارة منتهية',
        entryDateTime: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      SecurityVehicleEntity(
        id: '3',
        driverName: 'محمود علي',
        vehiclePlate: 'ز ح ط 9012',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:25 AM',
        queuePosition: 3,
        isApproved: true,
        entryDateTime: DateTime.now().subtract(const Duration(seconds: 10)),
      ),
    ];
  }

  @override
  Future<void> markAsHandled(String vehicleId) async {
    // ← عند ربط الـ API استبدل بـ:
    // await http.post(
    //   Uri.parse('$baseUrl/api/security/handled/$vehicleId'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );

    await Future.delayed(const Duration(milliseconds: 300));
  }
}
