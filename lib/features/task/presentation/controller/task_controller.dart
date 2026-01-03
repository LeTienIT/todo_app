import 'dart:async';
import 'package:riverpod_todo_app/features/task/domain/usecases/create_task_usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/usecases/get_task_usecase.dart';
import 'package:riverpod_todo_app/features/task/domain/usecases/toggle_task_usecase.dart';
import 'package:riverpod_todo_app/features/task/presentation/state/task_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/core/providers.dart';
import '../../domain/enities/task.dart';

final getTaskProvider = Provider<GetTaskUsecase>(
    (ref) => sl<GetTaskUsecase>()
);
final createTaskProvider = Provider<CreateTaskUsecase>(
        (ref) => sl<CreateTaskUsecase>()
);
final toggleTaskProvider = Provider<ToggleTaskUsecase>(
        (ref) => sl<ToggleTaskUsecase>()
);
final deleteTaskProvider = Provider<DeleteTaskUsecase>(
        (ref) => sl<DeleteTaskUsecase>()
);


final taskControllerProvider = NotifierProvider.autoDispose.family<TaskController, TaskState, String>(
  TaskController.new,
);
class TaskController extends AutoDisposeFamilyNotifier<TaskState, String> {
  late final GetTaskUsecase _getTaskUsecase;
  late final CreateTaskUsecase _createTaskUsecase;
  late final ToggleTaskUsecase _toggleTaskUsecase;
  late final DeleteTaskUsecase _deleteTaskUsecase;

  StreamSubscription<List<TaskEntity>>? _subscription;

  @override
  TaskState build(String arg) {
      final projectId = arg;

    _getTaskUsecase = ref.read(getTaskProvider);
    _createTaskUsecase = ref.read(createTaskProvider);
    _toggleTaskUsecase = ref.read(toggleTaskProvider);
    _deleteTaskUsecase = ref.read(deleteTaskProvider);

    if (projectId.isEmpty) {
      return TaskError('Project ID không hợp lệ');
    }

    state = TaskLoading();

    _subscription = _getTaskUsecase(projectId).listen(
          (tasks) => state = TaskLoaded(tasks),
          onError: (error) => state = TaskError(error.toString()),
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return state;
  }

  Future<void> createTask({required String title, String? assigneeId,}) async {
    final projectId = arg;

    state = TaskLoading();

    final result = await _createTaskUsecase(
      CreateTaskParams(projectId: projectId, title: title)
    );

    result.fold(
          (failure) => state = TaskError(failure.message),
          (_) {},
    );
  }

  Future<void> toggleTask(String taskId, bool isDone) async {
    final projectId = arg;
    final result = await _toggleTaskUsecase(
      ToggleTaskParams(
        projectId: projectId,
        taskId: taskId,
        isDone: isDone,
      ),
    );

    result.fold(
          (failure) => state = TaskError(failure.message),
          (_) {},
    );
  }

  Future<void> deleteTask(String taskId) async{
    final projectId = arg;

    final result = await _deleteTaskUsecase(DeleteTaskParams(projectId: projectId, taskId: taskId));

    result.fold(
        (failure) => state = TaskError(failure.message),
        (_) =>{}
    );
  }
}