// features/supervisor/domain/entities/supervisor_entity.dart

class SupervisorProfileEntity {
  final String fullName;
  final String idNumber;
  final String phone;
  final List<SupervisorLineEntity> lines;
  final String gateName;

  const SupervisorProfileEntity({
    required this.fullName,
    required this.idNumber,
    required this.phone,
    required this.lines,
    required this.gateName,
  });

  factory SupervisorProfileEntity.fromJson(Map<String, dynamic> json) {
    return SupervisorProfileEntity(
      fullName: json['full_name'] ?? '',
      idNumber: json['id_number'] ?? '',
      phone: json['phone'] ?? '',
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((e) => e is Map<String, dynamic>
              ? SupervisorLineEntity.fromJson(e)
              : SupervisorLineEntity(id: e.toString(), name: e.toString()))
          .toList(),
      gateName: json['gate_name'] ?? '',
    );
  }
}

// ── خط واحد (id + name) ───────────────────────────────────────────────────────
class SupervisorLineEntity {
  final String id;
  final String name;

  const SupervisorLineEntity({required this.id, required this.name});

  factory SupervisorLineEntity.fromJson(Map<String, dynamic> json) {
    return SupervisorLineEntity(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}
