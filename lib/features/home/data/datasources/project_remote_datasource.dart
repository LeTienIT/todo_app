import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/project_model.dart';
class ProjectRemoteDataSource {
  final FirebaseFirestore firestore;

  ProjectRemoteDataSource(this.firestore);

  Future<List<ProjectModel>> getProjects() async {
    final snapshot = await firestore.collection('projects').get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final docRef = await firestore.collection('projects').add({
      'name': project.name,
      'members': project.members,
      'deadline': project.deadline.toIso8601String(),
      "creator": project.creator
    });

    return ProjectModel(
      id: docRef.id,
      name: project.name,
      members: project.members,
      deadline: project.deadline,
      creator: project.creator,
    );
  }
}
