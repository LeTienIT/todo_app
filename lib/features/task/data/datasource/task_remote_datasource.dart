import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/enities/task.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSource(this.firestore);

  Stream<List<TaskEntity>> getTasksStream(String projectId) {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .withConverter<TaskModel>(
          fromFirestore: (snapshot, _) => TaskModel.fromFirestore(snapshot),
          toFirestore: (model, _) => model.toJson(),
        )
        .snapshots()
        .map(
            (querySnapshot) =>
              querySnapshot.docs
              .map((doc) => doc.data().toEntity())
              .toList()
    );
  }

  Future<TaskModel> createTask(String projectId, String title, String? assigneeId,) async {
    try {
      final ref = firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc();

      final task = TaskModel(
        id: ref.id,
        title: title,
        isDone: false,
        assigneeId: assigneeId,
        lastMessage: '',
        createdAt: DateTime.now(),
      );

      await ref.set(task.toJson());
      return task;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> toggleTask(String projectId, String taskId, bool isDone,) async {
    try {
      await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update({
            'isDone': isDone,
          });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    try {
      await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
