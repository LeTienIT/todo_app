import '../../domain/entities/project.dart';

class ProjectModel {
  final String id;
  final String name;
  final List<String> members;
  final DateTime deadline;
  final String creator;

  ProjectModel({
    required this.id,
    required this.name,
    required this.members,
    required this.deadline,
    required this.creator,
  });

  factory ProjectModel.fromJson(String id, Map<String, dynamic> json) {
    return ProjectModel(
      id: id,
      name: json['name'],
      members: List<String>.from(json['members']),
      deadline: DateTime.parse(json['deadline']),
      creator: json['creator'],
    );
  }

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      members: members,
      deadline: deadline,
      creator: creator
    );
  }
}
