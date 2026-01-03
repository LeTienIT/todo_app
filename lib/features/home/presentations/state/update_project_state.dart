import 'package:equatable/equatable.dart';

import '../../domain/entities/project.dart';

sealed class UpdateProjectState extends Equatable {
  const UpdateProjectState();

  @override
  List<Object?> get props => [];
}

class UpdateProjectInitial extends UpdateProjectState {
  const UpdateProjectInitial();

  @override
  List<Object?> get props => [];
}

class UpdateProjectLoading extends UpdateProjectState {
  const UpdateProjectLoading();

  @override
  List<Object?> get props => [];
}

class UpdateProjectError extends UpdateProjectState {
  final String message;

  const UpdateProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateProjectSuccess extends UpdateProjectState {
  final Project updatedProject;

  const UpdateProjectSuccess(this.updatedProject);

  @override
  List<Object?> get props => [updatedProject];
}