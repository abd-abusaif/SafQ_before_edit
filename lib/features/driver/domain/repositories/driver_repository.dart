// // features/driver/domain/repositories/driver_repository.dart

// import '../entities/queue_entry_entity.dart';

// abstract class DriverRepository {
//   Future<List<QueueEntryEntity>> getQueueList();
//   Future<QueueEntryEntity?> getMyQueueEntry(String idNumber);
//   Future<int> getAllowedSlots();
// }

// features/driver/domain/repositories/driver_repository.dart

import '../entities/queue_entry_entity.dart';
import '../entities/movement_order_entity.dart';

abstract class DriverRepository {
  Future<List<QueueEntryEntity>> getQueueList();
  Future<QueueEntryEntity?> getMyQueueEntry(String idNumber);
  Future<int> getAllowedSlots();

  /// أمر الحركة الخاص بالسائق (إن وُجد)
  /// API: GET /api/driver/movement-order/$idNumber
  Future<MovementOrderEntity?> getMovementOrder(String idNumber);
}
