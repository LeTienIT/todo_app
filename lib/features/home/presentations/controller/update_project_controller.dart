import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/get_member_chip_usecase.dart';
import 'package:riverpod_todo_app/features/home/domain/usecases/get_memberchip_byname_usecase.dart';
import 'package:riverpod_todo_app/features/home/presentations/state/update_project_state.dart';
import '../../../../core/providers.dart';
import '../../domain/entities/member_chip.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/update_project_usecase.dart';

final getMemberChipsUseCaseProvider = Provider<GetMemberChipUsecase>(
      (ref) => sl<GetMemberChipUsecase>(),
);
final getMemberChipByNameUseCaseProvider = Provider<GetMemberChipByNameUsecase>(
      (ref) => sl<GetMemberChipByNameUsecase>(),
);


final updateProjectsUseCaseProvider = Provider<UpdateProjectsUseCase>(
      (ref) => sl<UpdateProjectsUseCase>(),
);

final updateProjectControllerProvider = NotifierProvider<UpdateProjectController, UpdateProjectState>(
  UpdateProjectController.new
);
class UpdateProjectController extends Notifier<UpdateProjectState>{
  late final UpdateProjectsUseCase _updateProjectsUseCase;

  @override
  build() {
    _updateProjectsUseCase = ref.read(updateProjectsUseCaseProvider);

    return UpdateProjectInitial();
  }

  Future<void> updateProject(Project project) async {
    state = UpdateProjectLoading();

    final rs = await _updateProjectsUseCase(project);
    rs.fold(
        (failure) => state = UpdateProjectError(failure.message),
        (_) => state = UpdateProjectSuccess(project)
    );
  }
}