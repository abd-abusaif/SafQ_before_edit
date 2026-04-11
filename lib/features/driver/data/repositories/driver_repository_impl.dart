// features/driver/data/repositories/driver_repository_impl.dart
import '../../domain/entities/queue_entry_entity.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  @override
  Future<List<QueueEntryEntity>> getQueueList() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      QueueEntryEntity(
        queuePosition: 1,
        driverName: 'أحمد محمد',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:15 AM',
        exitTime: '7:30 AM',
        registrationNumber: 1,
        loadingValidityDate: now.add(const Duration(days: 5)),
      ),
      QueueEntryEntity(
        queuePosition: 2,
        driverName: 'محمود علي',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:20 AM',
        exitTime: '7:35 AM',
        registrationNumber: 2,
        loadingValidityDate: now.add(const Duration(days: 3)),
      ),
      QueueEntryEntity(
        queuePosition: 3,
        driverName: 'خالد إبراهيم',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:25 AM',
        exitTime: '7:40 AM',
        registrationNumber: 3,
        loadingValidityDate: now.add(const Duration(days: 7)),
      ),
      QueueEntryEntity(
        queuePosition: 4,
        driverName: 'يوسف سالم',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:30 AM',
        exitTime: '7:45 AM',
        registrationNumber: 4,
        loadingValidityDate: now.add(const Duration(days: 2)),
      ),
      QueueEntryEntity(
        queuePosition: 5,
        driverName: 'عبدالرحمن أبو سيف',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:35 AM',
        exitTime: '7:50 AM',
        registrationNumber: 5,
        // ← اقتراب من الانتهاء لإظهار التنبيه الأحمر
        loadingValidityDate: now.add(const Duration(hours: 18)),
      ),
      QueueEntryEntity(
        queuePosition: 6,
        driverName: 'سامي ناصر',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:40 AM',
        exitTime: '7:55 AM',
        registrationNumber: 6,
        loadingValidityDate: now.add(const Duration(days: 4)),
      ),
      QueueEntryEntity(
        queuePosition: 7,
        driverName: 'فارس عودة',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:45 AM',
        exitTime: '8:00 AM',
        registrationNumber: 7,
        loadingValidityDate: now.add(const Duration(days: 6)),
      ),
    ];
  }

  @override
  Future<QueueEntryEntity?> getMyQueueEntry(String idNumber) async {
    final list = await getQueueList();
    return list.firstWhere(
      (e) => e.queuePosition == 5,
      orElse: () => list.first,
    );
  }
}
