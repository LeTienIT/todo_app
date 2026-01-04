import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/enities/task.dart';
import 'package:riverpod_todo_app/features/task/domain/repositories/task_repository.dart';

import '../../../../core/error/failures.dart';

class UpdateTaskParams{
  String projectId;
  TaskEntity task;

  UpdateTaskParams(this.projectId, this.task);
}
class UpdateTaskUsecase implements UseCase<Unit, UpdateTaskParams>{
  final TaskRepository taskRepository;

  UpdateTaskUsecase(this.taskRepository);

  @override
  Future<Either<Failure, Unit>> call(UpdateTaskParams params) {
    return taskRepository.updateTask(params.projectId, params.task);
  }
}