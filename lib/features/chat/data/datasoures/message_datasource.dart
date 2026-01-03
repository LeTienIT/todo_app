import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../models/message_model.dart';

abstract class MessageDataSource {
  Stream<List<MessageModel>> streamMessages(String projectId, String taskId);

  Future<String> sendMessage(MessageModel message);

  Future<List<MessageModel>> loadMoreMessages({required String projectId, required String taskId, required DocumentSnapshot lastDoc,});

  Future<DocumentSnapshot> getMessageSnapshot({required String projectId, required String taskId, required String messageId,});

  Future<Unit> deleteMessage(String projectId, String taskId, String messageId);

}
