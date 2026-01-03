import '../entities/project.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ProjectRepository {
  Stream<List<Project>> getProjects();

  Future<Either<Failure, Project>> createProject(Project p);

  Future<Either<Failure, Unit>> deleteProject(String pId);

  Future<Either<Failure, Unit>> updateProject(Project project);
}
