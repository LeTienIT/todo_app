
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteMessageParams{
  String projectId;
  String taskId;
  String messageId;

  DeleteMessageParams(this.projectId, this.taskId, this.messageId);
}

class DeleteMessage implements UseCase<Unit, DeleteMessageParams>{
  final MessageRepository messageRepository;
  DeleteMessage(this.messageRepository);
  @override
  Future<Either<Failure, Unit>> call(DeleteMessageParams params) {
    return messageRepository.deleteMessage(params.projectId, params.taskId, params.messageId);
  }

}