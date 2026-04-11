// features/driver/data/repositories/driver_repository_impl.dart
import '../../domain/entities/queue_entry_entity.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  @override
  Future<List<QueueEntryEntity>> getQueueList() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      const QueueEntryEntity(
        queuePosition: 1,
        driverName: 'أحمد محمد',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:15 AM',
        exitTime: '7:30 AM',
        registrationNumber: 1,
      ),
      const QueueEntryEntity(
        queuePosition: 2,
        driverName: 'محمود علي',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:20 AM',
        exitTime: '7:35 AM',
        registrationNumber: 2,
      ),
      const QueueEntryEntity(
        queuePosition: 3,
        driverName: 'خالد إبراهيم',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:25 AM',
        exitTime: '7:40 AM',
        registrationNumber: 3,
      ),
      const QueueEntryEntity(
        queuePosition: 4,
        driverName: 'يوسف سالم',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:30 AM',
        exitTime: '7:45 AM',
        registrationNumber: 4,
      ),
      const QueueEntryEntity(
        queuePosition: 5,
        driverName: 'عبدالرحمن أبو سيف',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:35 AM',
        exitTime: '7:50 AM',
        registrationNumber: 5,
      ),
      const QueueEntryEntity(
        queuePosition: 6,
        driverName: 'سامي ناصر',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:40 AM',
        exitTime: '7:55 AM',
        registrationNumber: 6,
      ),
      const QueueEntryEntity(
        queuePosition: 7,
        driverName: 'فارس عودة',
        lineFrom: 'الخليل',
        lineTo: 'دورا',
        entryTime: '7:45 AM',
        exitTime: '8:00 AM',
        registrationNumber: 7,
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
