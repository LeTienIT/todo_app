import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/repositories/task_repository.dart';

class DeleteTaskParams{
  String projectId;
  String taskId;
  DeleteTaskParams({required this.projectId, required this.taskId});
}
class DeleteTaskUsecase implements UseCase<Unit, DeleteTaskParams>{
  final TaskRepository taskRepository;
  DeleteTaskUsecase(this.taskRepository);

  @override
  Future<Either<Failure, Unit>> call(DeleteTaskParams params) {
    return taskRepository.deleteTask(params.projectId, params.taskId);
  }

}