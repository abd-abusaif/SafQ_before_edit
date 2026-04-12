// features/driver/data/repositories/violation_repository_impl.dart

import '../../domain/entities/violation_entity.dart';
import '../../domain/repositories/violation_repository.dart';

class ViolationRepositoryImpl implements ViolationRepository {
  @override
  Future<List<ViolationEntity>> getMyViolations(String idNumber) async {
    // API: GET /api/driver/violations/$idNumber
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/driver/violations/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // final List data = jsonDecode(response.body);
    // if (data.isEmpty) return [];
    // return data.map((e) => ViolationEntity.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const ViolationEntity(
        id: '1',
        violationNumber: 'V-2026-001',
        type: 'مخالفة سرعة زائدة',
        amount: 150.0,
        notes: 'تجاوز السرعة المحددة داخل المجمع',
        blockEntry: false,
        date: '2026-03-10',
      ),
      const ViolationEntity(
        id: '2',
        violationNumber: 'V-2026-002',
        type: 'مخالفة عدم دفع الرسوم',
        amount: 300.0,
        notes: null,
        blockEntry: true,
        date: '2026-03-15',
      ),
    ];

    // جرّب بدون مخالفات:
    // return [];
  }
}
