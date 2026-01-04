import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/features/task/data/datasource/task_remote_datasource.dart';
import 'package:riverpod_todo_app/features/task/data/models/task_model.dart';
import 'package:riverpod_todo_app/features/task/domain/enities/task.dart';
import 'package:riverpod_todo_app/features/task/domain/repositories/task_repository.dart';

import '../../../../core/error/exceptions.dart';

class TaskRepositoryImpl implements TaskRepository{
  final TaskRemoteDataSource taskRemoteDataSource;

  TaskRepositoryImpl(this.taskRemoteDataSource);

  @override
  Future<Either<Failure, TaskEntity>> createTask(String projectId, String title, String? assigneeId) async {
    try {
      final taskModel = await taskRemoteDataSource.createTask(projectId, title, assigneeId,);
      return Right(taskModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Create task failed'));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Stream<List<TaskEntity>> getTasks(String projectId) {
    return taskRemoteDataSource.getTasksStream(projectId);
  }

  @override
  Future<Either<Failure, Unit>> toggleTask(String projectId, String taskId, bool isDone) async {
    try {
      await taskRemoteDataSource.toggleTask(projectId, taskId, isDone,);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Update task failed'));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String projectId, String taskId) async {
    try {
      await taskRemoteDataSource.deleteTask(projectId, taskId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Delete task failed'));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTask(String projectId, TaskEntity task) async {
    try {
      TaskModel taskModel = TaskModel(
          id: task.id,
          title: task.title,
          isDone: task.isDone,
          assigneeId: task.assigneeId,
          lastMessage: task.lastMessage,
          createdAt: task.createdAt
      );
      await taskRemoteDataSource.updateTask(projectId, taskModel);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Update task failed'));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

}