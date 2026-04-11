import '../../domain/entities/violation_entity.dart';
import '../../domain/repositories/violation_repository.dart';

class ViolationRepositoryImpl implements ViolationRepository {
  @override
  Future<List<ViolationEntity>> getMyViolations(String idNumber) async {
    // ← عند ربط الـ API استبدل بـ:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/api/violations/$idNumber'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // final List data = jsonDecode(response.body);
    // if (data.isEmpty) return []; // ← مهم: لا يضرب البرنامج
    // return data.map((e) => ViolationEntity.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 500));

    // ← Mock: جرب الحالتين
    return [
      const ViolationEntity(
        id: '1',
        violationNumber: 'V-2026-001',
        type: 'مخالفة سرعة زائدة',
        amount: 150.0,
        notes: 'تجاوز السرعة المحددة داخل المجمع',
        blockEntry: false, // ← بدون منع
        date: '2026-03-10',
      ),
      const ViolationEntity(
        id: '2',
        violationNumber: 'V-2026-002',
        type: 'مخالفة عدم دفع الرسوم',
        amount: 300.0,
        notes: null,
        blockEntry: true, // ← مع منع الدخول
        date: '2026-03-15',
      ),
    ];

    // ← Mock: جرب بدون مخالفات
    // return [];
  }
}
