import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  file,
}

class Message extends Equatable{
  final String id;
  final String projectId;
  final String taskId;
  final String senderId;
  final String? senderName;
  final String content;
  final MessageType type;
  final DateTime createdAt;

  const Message({required this.id, required this.projectId, required this.taskId, required this.senderId, required this.type, required this.content, required this.createdAt, this.senderName});

  Message copyWith({
    String? id,
    String? projectId,
    String? taskId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    String? senderName,
  }) {
    return Message(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      senderName:  senderName ?? this.senderName,
    );
  }
  @override
  List<Object?> get props => [id, projectId, taskId, senderId, content, createdAt, type, senderName ];

}