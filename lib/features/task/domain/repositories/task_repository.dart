import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../enities/task.dart';

abstract class TaskRepository{
  Stream<List<TaskEntity>> getTasks(String projectId);
  Future<Either<Failure, TaskEntity>> createTask(String projectId, String title, String? assigneeId,);
  Future<Either<Failure, Unit>> toggleTask(String projectId, String taskId, bool isDone,);

  Future<Either<Failure, Unit>> deleteTask(String projectId, String taskId,);

  Future<Either<Failure, Unit>> updateTask(String projectId, TaskEntity task);
}