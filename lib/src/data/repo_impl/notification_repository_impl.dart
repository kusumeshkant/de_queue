import 'package:dq_app/src/data/datasources/remote/notification_remote_ds.dart';
import 'package:dq_app/src/domain/repo/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;
  const NotificationRepositoryImpl({required this.remote});

  @override
  Future<void> updateFcmToken(String token) => remote.updateFcmToken(token);
}
