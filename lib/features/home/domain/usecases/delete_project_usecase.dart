import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import '../entities/project.dart';
import '../../../../core/error/failures.dart';
import '../repository/project_repository.dart';

class DeleteProjectsUseCase implements UseCase<Unit, String> {
  final ProjectRepository repository;

  DeleteProjectsUseCase(this.repository);

  Future<Either<Failure, Unit>> call(pragma) {
    return repository.deleteProject(pragma);
  }
}