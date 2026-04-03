import '../repo/notification_repository.dart';

class UpdateFcmTokenUseCase {
  final NotificationRepository repository;
  const UpdateFcmTokenUseCase({required this.repository});

  Future<void> execute(String token) => repository.updateFcmToken(token);
}
