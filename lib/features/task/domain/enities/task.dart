class TaskEntity{
  final String id;
  final String title;
  final bool isDone;
  final String? assigneeId;
  final DateTime createdAt;

  TaskEntity({
    required this.id,
    required this.title,
    required this.isDone,
    this.assigneeId,
    required this.createdAt,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? assigneeId,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      assigneeId: assigneeId ?? this.assigneeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}