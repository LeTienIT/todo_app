
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';

abstract class MessageRepository{
  Stream<List<Message>> streamMessage(String projectId, String taskId);

  Future<Either<Failure, String>> sendMessage(Message message);

  Future<Either<Failure, List<Message>>> loadMoreMessages({ required String projectId, required String taskId, required Message lastMessage});

  Future<Either<Failure, Unit>> deleteMessage(String projectId, String taskId, String messageId);

}