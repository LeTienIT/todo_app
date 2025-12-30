import '../entities/project.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();

  Future<Either<Failure, Project>> createProject(Project p);
}
