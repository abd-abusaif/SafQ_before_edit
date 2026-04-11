class ViolationEntity {
  final String id;
  final String violationNumber;
  final String type;
  final double amount;
  final String? notes;
  final bool blockEntry; // ← true = منع الدخول, false = بدون منع
  final String date;

  const ViolationEntity({
    required this.id,
    required this.violationNumber,
    required this.type,
    required this.amount,
    this.notes,
    required this.blockEntry,
    required this.date,
  });

  factory ViolationEntity.fromJson(Map<String, dynamic> json) {
    return ViolationEntity(
      id: json['id'] ?? '',
      violationNumber: json['violation_number'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      blockEntry: json['block_entry'] ?? false,
      date: json['date'] ?? '',
    );
  }
}
