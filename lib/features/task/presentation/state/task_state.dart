import '../../domain/enities/task.dart';

sealed class TaskState {
  const TaskState();
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  const TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
}
