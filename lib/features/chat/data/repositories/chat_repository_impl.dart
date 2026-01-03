import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/features/chat/data/datasoures/message_datasource.dart';
import 'package:riverpod_todo_app/features/chat/data/models/message_model.dart';
import 'package:riverpod_todo_app/features/chat/domain/entities/chat_entity.dart';
import 'package:riverpod_todo_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/error/exceptions.dart';

class ChatRepositoryImpl implements MessageRepository{
  final MessageDataSource messageDataSource;

  ChatRepositoryImpl(this.messageDataSource);


  @override
  Future<Either<Failure, Unit>> deleteMessage(String projectId, String taskId, String messageId) async {
    try{
      await messageDataSource.deleteMessage(projectId, taskId, messageId);
      return Right(unit);
    }
    on ServerException catch(e){
      return Left(ServerFailure("Lỗi"));
    }
    catch(e){
      return Left(ServerFailure("Error: $e"));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> loadMoreMessages({required String projectId, required String taskId, required Message lastMessage}) async {
    try{
      final lastDoc = await messageDataSource.getMessageSnapshot(projectId: projectId, taskId: taskId, messageId: lastMessage.id,);

      final models = await messageDataSource.loadMoreMessages(projectId: projectId, taskId: taskId, lastDoc: lastDoc,);

      return Right(models);
    }
    on ServerException catch (e){
      return Left(ServerFailure("Đã xảy ra lỗi từ server"));
    }
    catch (e){
      return Left(ServerFailure("Đã xảy ra lỗi"));
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage(Message message) async {
    try{
      final model = MessageModel(
          id: message.id,
          projectId: message.projectId,
          taskId: message.taskId,
          senderId: message.senderId,
          content: message.content,
          type: message.type,
          createdAt: message.createdAt
      );
      final newId = await messageDataSource.sendMessage(model);

      return Right(newId);

    }catch(e){
      return Left(ServerFailure("$e"));
    }
  }

  @override
  Stream<List<Message>> streamMessage(String projectId, String taskId) {
    return messageDataSource.streamMessages(projectId, taskId);
  }

}