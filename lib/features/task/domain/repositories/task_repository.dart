import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../enities/task.dart';

abstract class TaskRepository{
  Future<Either<Failure, List<TaskEntity>>> getTasks(String projectId);
  Future<Either<Failure, TaskEntity>> createTask(String projectId, String title, String assigneeId,);
  Future<Either<Failure, void>> toggleTask(String projectId, String taskId, bool isDone,);
}