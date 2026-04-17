// features/driver/domain/repositories/driver_repository.dart

import '../entities/queue_entry_entity.dart';

abstract class DriverRepository {
  Future<List<QueueEntryEntity>> getQueueList();
  Future<QueueEntryEntity?> getMyQueueEntry(String idNumber);
  Future<int> getAllowedSlots();
}
