import 'package:dartz/dartz.dart';
import 'package:riverpod_todo_app/core/error/failures.dart';
import 'package:riverpod_todo_app/features/home/data/datasources/project_remote_datasource.dart';
import 'package:riverpod_todo_app/features/home/domain/entities/project.dart';
import 'package:riverpod_todo_app/features/home/domain/repository/project_repository.dart';

import '../model/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository{
  final ProjectRemoteDataSource remote;

  ProjectRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final models = await remote.getProjects();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (_) {
      return Left(ServerFailure('Cannot load projects'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      final model = ProjectModel(
        id: '',
        name: project.name,
        members: project.members,
        deadline: project.deadline,
        creator: project.creator,
      );

      final created = await remote.createProject(model);
      return Right(created.toEntity());
    } catch (_) {
      return Left(ServerFailure('Cannot create project'));
    }
  }

}