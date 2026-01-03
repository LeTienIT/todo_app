import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import '../entities/project.dart';
import '../../../../core/error/failures.dart';
import '../repository/project_repository.dart';

class UpdateProjectsUseCase implements UseCase<Unit, Project> {
  final ProjectRepository repository;

  UpdateProjectsUseCase(this.repository);

  Future<Either<Failure, Unit>> call(pragma) {
    return repository.updateProject(pragma);
  }
}
