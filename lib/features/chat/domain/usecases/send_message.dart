import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';


class SendMessage implements UseCase<String, Message>{
  final MessageRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, String>> call(Message params) {
    return repository.sendMessage(params);
  }

}