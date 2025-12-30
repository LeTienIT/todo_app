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
}