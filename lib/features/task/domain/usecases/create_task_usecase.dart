import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/enities/task.dart';
import 'package:riverpod_todo_app/features/task/domain/repositories/task_repository.dart';

class CreateTaskParams{
  String projectId;
  String title;
  String? assigneeId;
  CreateTaskParams({required this.projectId, required this.title, this.assigneeId});
}
class CreateTaskUsecase implements UseCase<TaskEntity, CreateTaskParams>{
  final TaskRepository taskRepository;
  CreateTaskUsecase(this.taskRepository);
  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) {
   return taskRepository.createTask(params.projectId, params.title, params.assigneeId);
  }

}