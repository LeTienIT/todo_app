import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/create_project_usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/project_list_usecase.dart';
import 'package:riverpod_todo_app/features/home/presentations/state/project_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/core/providers.dart';

final getProjectsUseCaseProvider = Provider<GetProjectsUseCase>(
      (ref) => sl<GetProjectsUseCase>(),
);

final createProjectsUseCaseProvider = Provider<CreateProjectsUseCase>(
      (ref) => sl<CreateProjectsUseCase>(),
);


final projectControllerProvider = NotifierProvider<ProjectController, ProjectState>(
  ProjectController.new,
);
class ProjectController extends Notifier<ProjectState>{
  late final GetProjectsUseCase _getProjectsUseCase;
  late final CreateProjectsUseCase _createProjectsUseCase;

  @override
  ProjectState build() {
    _getProjectsUseCase = ref.read(getProjectsUseCaseProvider);
    _createProjectsUseCase = ref.read(createProjectsUseCaseProvider);

    loadProjects();

    return ProjectInitial();
  }

  Future<void> loadProjects() async {
    //print("START LOAD");
    state = ProjectLoading();

    final result = await _getProjectsUseCase(NoParams());

    result.fold(
          (failure) => state = ProjectError(failure.message),
          (projects) => state = ProjectLoaded(projects),
    );
    //print("loaded");
  }

  Future<void> createProject(String name, List<String> members, DateTime deadline, String creator)async{
    state = ProjectLoading();

    final rs = await _createProjectsUseCase(CreateProjectParams(name, members, deadline, creator));

    rs.fold(
        (failure) => state = ProjectError(failure.message),
        (p) => state = CreatedProject(p)
    );
  }
}