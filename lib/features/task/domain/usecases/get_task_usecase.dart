import 'package:riverpod_todo_app/features/task/domain/enities/task.dart';
import 'package:riverpod_todo_app/features/task/domain/repositories/task_repository.dart';

class GetTaskUsecase{
  final TaskRepository taskRepository;
  GetTaskUsecase(this.taskRepository);

  @override
  Stream<List<TaskEntity>> call(String params) {
    return taskRepository.getTasks(params);
  }

}