// data/models/task_model.dart
import 'package:riverpod_todo_app/features/task/domain/enities/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    required super.isDone,
    required super.assigneeId,
    required super.createdAt,
  });

  /// Firestore → Model
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      title: data['title'] as String,
      isDone: data['isDone'] as bool,
      assigneeId: data['assigneeId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'assigneeId': assigneeId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      isDone: isDone,
      assigneeId: assigneeId,
      createdAt: createdAt,
    );
  }
}
