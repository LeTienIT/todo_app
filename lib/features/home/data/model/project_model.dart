import '../../domain/entities/project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProjectModel(
      id: doc.id,
      name: data['name'] as String,
      creator: data['creator'] as String,
      members: (data['members'] as List<dynamic>?)?.cast<String>() ?? [],
      deadline: DateTime.parse(data['deadline']),
    );
  }

  factory ProjectModel.fromJson(String id, Map<String, dynamic> json) {
    return ProjectModel(
      id: id,
      name: json['name'],
      members: List<String>.from(json['members']),
      deadline: DateTime.parse(json['deadline']),
      creator: json['creator'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'creator': creator,
      'members': members,
      'deadline': deadline,
    };
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

  factory ProjectModel.fromEntity(Project entity) {
    return ProjectModel(
      id: entity.id ?? '',
      name: entity.name,
      members: entity.members,
      deadline: entity.deadline,
      creator: entity.creator,
    );
  }
}
