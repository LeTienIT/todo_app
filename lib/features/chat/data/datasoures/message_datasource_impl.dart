import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../models/message_model.dart';
import 'message_datasource.dart';

class MessageDataSourceImpl implements MessageDataSource {
  final FirebaseFirestore firestore;

  MessageDataSourceImpl(this.firestore);

  @override
  Stream<List<MessageModel>> streamMessages(String projectId, String taskId) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection("messages")
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
          MessageModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<DocumentSnapshot> getMessageSnapshot({required String projectId, required String taskId, required String messageId,}) async {
    try{
      final doc = await firestore
          .collection('projects')
          .doc(projectId)
          .collection("tasks")
          .doc(taskId)
          .collection("messages")
          .doc(messageId)
          .get();

      if (!doc.exists) {
        throw ServerException(message: 'Last message not found');
      }

      return doc;
    }
    catch (e){
      if(e is ServerException){
        rethrow;
      }
      else{
        throw ServerException(message: "Error $e");
      }
    }
  }

  @override
  Future<List<MessageModel>> loadMoreMessages({required String projectId, required String taskId, required DocumentSnapshot lastDoc,}) async {
    try{
      final snapshot = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection("messages")
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDoc)
          .limit(30)
          .get();

      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
          .toList();
    }
    catch (e){
      throw ServerException(message: "Error: $e");
    }
  }

  @override
  Future<String> sendMessage(MessageModel message) async {
    try{
      final messageRef = firestore
          .collection('projects')
          .doc(message.projectId)
          .collection('tasks')
          .doc(message.taskId)
          .collection("messages")
          .doc();
      final newId = messageRef.id;
      final updatedModel = message.copyWith(id: newId);
      await messageRef.set(updatedModel.toJson());

      await firestore
          .collection('projects')
          .doc(message.projectId)
          .collection("tasks")
          .doc(message.taskId)
          .update({
            'lastMessage': message.content,
            'createdAt': DateTime.now(),
          });

      return newId;
    }catch (e){
      throw ServerException(message: "Error: $e");
    }
  }

  @override
  Future<Unit> deleteMessage(String projectId, String taskId, String messageId) async {
    try{
      final messageRef = firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection("messages")
          .doc(messageId);

      await messageRef.delete();

      return unit;
    }catch(e){
      throw ServerException(message: "Error $e");
    }
  }
}
