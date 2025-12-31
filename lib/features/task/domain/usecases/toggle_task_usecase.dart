import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/repositories/task_repository.dart';

class ToggleTaskParams{
  String projectId;
  String taskId;
  bool isDone;
  ToggleTaskParams({required this.projectId, required this.taskId, required this.isDone});
}
class ToggleTaskUsecase implements UseCase<Unit, ToggleTaskParams>{
  final TaskRepository taskRepository;
  ToggleTaskUsecase(this.taskRepository);

  @override
  Future<Either<Failure, Unit>> call(ToggleTaskParams params) {
    return taskRepository.toggleTask(params.projectId, params.taskId, params.isDone);
  }

}