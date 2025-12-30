import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import '../entities/project.dart';
import '../../../../core/error/failures.dart';
import '../repository/project_repository.dart';

class GetProjectsUseCase implements UseCase<List<Project>, NoParams> {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Project>>> call(NoParams) {
    return repository.getProjects();
  }
}
