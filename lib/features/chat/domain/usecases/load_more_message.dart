import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class LoadMoreParams{
  String projectId;
  String taskId;
  Message lastMessage;

  LoadMoreParams({required this.projectId, required this.taskId, required this.lastMessage});

}
class LoadMoreMessages {
  final MessageRepository repository;

  LoadMoreMessages(this.repository);

  Future<Either<Failure, List<Message>>> call(LoadMoreParams params,) {
    return repository.loadMoreMessages(
      projectId: params.projectId,
      taskId: params.taskId,
      lastMessage: params.lastMessage,
    );
  }
}
