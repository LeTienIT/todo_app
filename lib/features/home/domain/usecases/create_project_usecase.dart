import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/usecases/usecase.dart';
import '../entities/project.dart';
import '../../../../core/error/failures.dart';
import '../repository/project_repository.dart';

class CreateProjectParams{
  String name;
  List<String> members;
  DateTime deadline;
  String creator;

  CreateProjectParams(this.name, this.members, this.deadline, this.creator);

}
class CreateProjectsUseCase implements UseCase<Project, CreateProjectParams> {
  final ProjectRepository repository;

  CreateProjectsUseCase(this.repository);

  Future<Either<Failure, Project>> call(pragma) {
    return repository.createProject(
        Project(
          name : pragma.name,
          members: pragma.members,
          deadline: pragma.deadline,
          creator: pragma.creator,
        )
    );
  }
}
