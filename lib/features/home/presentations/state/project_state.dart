import '../../domain/entities/project.dart';

sealed class ProjectState {
  const ProjectState();
}

class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;
  const ProjectLoaded(this.projects);
}

class ProjectError extends ProjectState {
  final String message;
  const ProjectError(this.message);
}

class CreatedProject extends ProjectState{
  final Project p;

  CreatedProject(this.p);
}