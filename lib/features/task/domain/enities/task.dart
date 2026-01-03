class TaskEntity{
  final String id;
  final String title;
  final bool isDone;
  final String? assigneeId;
  final String? lastMessage;
  final DateTime createdAt;

  TaskEntity({
    required this.id,
    required this.title,
    required this.isDone,
    this.assigneeId,
    this.lastMessage,
    required this.createdAt,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? assigneeId,
    String? lastMessage,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      assigneeId: assigneeId ?? this.assigneeId,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}