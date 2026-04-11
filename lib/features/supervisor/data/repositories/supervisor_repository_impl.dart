import '../../domain/entities/supervisor_entity.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../../domain/entities/supervisor_stats_entity.dart';
import '../../domain/entities/supervisor_vehicle_entity.dart';

class SupervisorRepositoryImpl implements SupervisorRepository {
  @override
  Future<List<String>> getMyLines(String idNumber) async {
    // ← عند ربط الـ API:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/supervisor/lines/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // return List<String>.from(jsonDecode(response.body)['lines']);

    await Future.delayed(const Duration(milliseconds: 300));
    return ['الخليل / دورا', 'الخليل / بيت لحم'];
  }

  @override
  Future<SupervisorStatsEntity> getStats(String idNumber, String lineId) async {
    // ← عند ربط الـ API:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/supervisor/stats/$idNumber/$lineId'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // return SupervisorStatsEntity.fromJson(jsonDecode(response.body));

    await Future.delayed(const Duration(milliseconds: 500));
    return const SupervisorStatsEntity(
      activeVehicles: 12,
      waitingVehicles: 7,
      completedTrips: 20,
    );
  }

  @override
  Future<List<SupervisorVehicleEntity>> getVehicles(
    String idNumber,
    String lineId,
  ) async {
    // ← عند ربط الـ API:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/supervisor/vehicles/$idNumber/$lineId'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // final List data = jsonDecode(response.body);
    // return data.map((e) => SupervisorVehicleEntity.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const SupervisorVehicleEntity(
        driverName: 'أحمد محمد',
        vehiclePlate: 'أ ب ج 1234',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:15 AM',
        queuePosition: 1,
        isApproved: true,
      ),
      const SupervisorVehicleEntity(
        driverName: 'خالد إبراهيم',
        vehiclePlate: 'د هـ و 5678',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:20 AM',
        queuePosition: 2,
        isApproved: false,
        rejectionReason: 'رخصة السيارة منتهية',
      ),
      const SupervisorVehicleEntity(
        driverName: 'محمود علي',
        vehiclePlate: 'ز ح ط 9012',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:25 AM',
        queuePosition: 3,
        isApproved: true,
      ),
    ];
  }

  @override
  Future<SupervisorProfileEntity> getProfile(String idNumber) async {
    // ← عند ربط الـ API:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/supervisor/profile/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // return SupervisorProfileEntity.fromJson(jsonDecode(response.body));

    await Future.delayed(const Duration(milliseconds: 500));
    return SupervisorProfileEntity(
      fullName: 'محمد رامي إبراهيم عودة',
      idNumber: idNumber,
      phone: '0599112233',
      lines: ['الخليل / دورا', 'الخليل / بيت لحم'],
      gateName: 'بوابة شارع بئر السبع',
    );
  }
}
