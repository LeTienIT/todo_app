import 'dart:async';

import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/create_project_usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/delete_project_usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/project_list_usecase.dart';
import 'package:riverpod_todo_app/features/home/presentations/state/project_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/core/providers.dart';

import '../../domain/entities/project.dart';
import '../../domain/usecases/update_project_usecase.dart';

final getProjectsUseCaseProvider = Provider<GetProjectsUseCase>(
      (ref) => sl<GetProjectsUseCase>(),
);
final createProjectsUseCaseProvider = Provider<CreateProjectsUseCase>(
      (ref) => sl<CreateProjectsUseCase>(),
);
final deleteProjectsUseCaseProvider = Provider<DeleteProjectsUseCase>(
      (ref) => sl<DeleteProjectsUseCase>(),
);


final projectControllerProvider = NotifierProvider<ProjectController, ProjectState>(
  ProjectController.new,
);
class ProjectController extends Notifier<ProjectState>{
  late final GetProjectsUseCase _getProjectsUseCase;
  late final CreateProjectsUseCase _createProjectsUseCase;
  late final DeleteProjectsUseCase _deleteProjectsUseCase;


  late final StreamSubscription<List<Project>>? _subscription;

  @override
  ProjectState build() {
    _getProjectsUseCase = ref.read(getProjectsUseCaseProvider);
    _createProjectsUseCase = ref.read(createProjectsUseCaseProvider);
    _deleteProjectsUseCase = ref.read(deleteProjectsUseCaseProvider);


    state = ProjectInitial();

    _subscription = _getProjectsUseCase(NoParams()).listen(
        (data) => state = ProjectLoaded(data),
        onError: (e) => state = ProjectError(e.toString())
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return state;
  }

  Future<void> createProject(String name, List<String> members, DateTime deadline, String creator)async{
    final currentState = state;
    if(currentState is! ProjectLoaded){
      return;
    }
    state = ProjectLoading();

    final rs = await _createProjectsUseCase(CreateProjectParams(name, members, deadline, creator));

    rs.fold(
        (failure) => state = ProjectError(failure.message),
        (p) {
          state = CreatedProject(p);
          Future.delayed(Duration(seconds: 1));
          if(currentState is ProjectLoaded){
            currentState.projects.add(p);
          }
          state = currentState;
        }
    );
  }

  Future<void> deleteProject(String pId) async {
    state = ProjectLoading();

    final rs = await _deleteProjectsUseCase(pId);

    rs.fold(
            (failure) => state = ProjectError(failure.message),
            (_) => {}
    );
  }
}