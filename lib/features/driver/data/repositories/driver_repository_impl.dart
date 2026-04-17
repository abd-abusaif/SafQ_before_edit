// features/driver/data/repositories/driver_repository_impl.dart

import '../../domain/entities/queue_entry_entity.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  @override
  Future<List<QueueEntryEntity>> getQueueList() async {
    // API: GET /api/driver/queue
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      QueueEntryEntity(
        queuePosition: 1,
        driverName: 'أحمد محمد',
        vehicleNumber: '6 2181-10',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:15 ص',
        exitTime: '7:30 ص',
        registrationNumber: 1,
        loadingValidityDate: now.add(const Duration(days: 5)),
      ),
      QueueEntryEntity(
        queuePosition: 2,
        driverName: 'محمود علي',
        vehicleNumber: '6 2181-20',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:20 ص',
        exitTime: '7:35 ص',
        registrationNumber: 2,
        loadingValidityDate: now.add(const Duration(days: 3)),
      ),
      QueueEntryEntity(
        queuePosition: 3,
        driverName: 'خالد إبراهيم',
        vehicleNumber: '6 2181-30',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:25 ص',
        exitTime: '7:40 ص',
        registrationNumber: 3,
        loadingValidityDate: now.add(const Duration(days: 7)),
      ),
      QueueEntryEntity(
        queuePosition: 4,
        driverName: 'يوسف سالم',
        vehicleNumber: '6 2181-40',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:30 ص',
        exitTime: '7:45 ص',
        registrationNumber: 4,
        loadingValidityDate: now.add(const Duration(days: 2)),
      ),
      QueueEntryEntity(
        queuePosition: 5,
        driverName: 'عبدالرحمن أبو سيف',
        vehicleNumber: '6 2181-50',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:35 ص',
        exitTime: '7:50 ص',
        registrationNumber: 5,
        loadingValidityDate: now.add(const Duration(hours: 18)),
      ),
      QueueEntryEntity(
        queuePosition: 6,
        driverName: 'سامي ناصر',
        vehicleNumber: '6 2181-60',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:40 ص',
        exitTime: '7:55 ص',
        registrationNumber: 6,
        loadingValidityDate: now.add(const Duration(days: 4)),
      ),
      QueueEntryEntity(
        queuePosition: 7,
        driverName: 'فارس عودة',
        vehicleNumber: '6 2181-70',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:45 ص',
        exitTime: '8:00 ص',
        registrationNumber: 7,
        loadingValidityDate: now.add(const Duration(days: 6)),
      ),
    ];
  }

  @override
  Future<QueueEntryEntity?> getMyQueueEntry(String idNumber) async {
    // API: GET /api/driver/queue/me/$idNumber
    final list = await getQueueList();
    return list.firstWhere(
      (e) => e.queuePosition == 5,
      orElse: () => list.first,
    );
  }

  /// عدد الخانات المسموح بالتحميل فيها حالياً
  /// API: GET /api/driver/queue/allowed-slots
  Future<int> getAllowedSlots() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock: أول 3 مراكب مسموح لها بالتحميل
    return 3;
  }
}
