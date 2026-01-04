import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_todo_app/core/error/exceptions.dart';

import '../../domain/entities/project.dart';
import '../model/project_model.dart';
class ProjectRemoteDataSource {
  final FirebaseFirestore firestore;

  ProjectRemoteDataSource(this.firestore);

  Stream<List<Project>> getProjectsStream() {
    return firestore
        .collection('projects')
        .withConverter<ProjectModel>(
          fromFirestore: (snapshot, _) => ProjectModel.fromFirestore(snapshot),
          toFirestore: (model, _) => model.toJson(),
        )
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) => doc.data().toEntity()).toList());
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

  Future<void> deleteProjectWithTasks(String projectId) async {
    final projectRef =
    firestore.collection('projects').doc(projectId);

    final tasksSnapshot = await projectRef
        .collection('tasks')
        .get();

    for (final taskDoc in tasksSnapshot.docs) {
      final messagesSnapshot = await taskDoc.reference
          .collection('messages')
          .get();

      // Batch xóa messages
      final messageBatch = firestore.batch();
      for (final msg in messagesSnapshot.docs) {
        messageBatch.delete(msg.reference);
      }
      await messageBatch.commit();

      // Xóa task
      await taskDoc.reference.delete();
    }

    await projectRef.delete();
  }


  Future<void> updateProject(ProjectModel projectModel) async {
    try {
      await firestore
          .collection("projects")
          .doc(projectModel.id)
          .update({
            'name': projectModel.name,
            'members': projectModel.members,
            'deadline': projectModel.deadline.toIso8601String(),
          });
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Firestore update failed: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Update project failed: $e');
    }
  }
}
