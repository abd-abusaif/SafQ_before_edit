class SupervisorProfileEntity {
  final String fullName;
  final String idNumber;
  final String phone;
  final List<String> lines;
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
      lines: List<String>.from(json['lines'] ?? []),
      gateName: json['gate_name'] ?? '',
    );
  }
}
