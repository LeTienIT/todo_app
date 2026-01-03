
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_entity.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.projectId,
    required super.taskId,
    required super.senderId,
    required super.content,
    required super.type,
    required super.createdAt,
    super.senderName
  });

  factory MessageModel.fromJson(
      Map<String, dynamic> json,
      String id,
      ) {
    return MessageModel(
      id: id,
      projectId: json['projectId'],
      taskId: json['taskId'],
      senderId: json['senderId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      senderName: json['senderName'] ?? "NoName"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'taskId': taskId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'senderName' : senderName,
    };
  }

  @override
  MessageModel copyWith({
    String? id,
    String? projectId,
    String? taskId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    String? senderName,
  }) {
    return MessageModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName
    );
  }
}
