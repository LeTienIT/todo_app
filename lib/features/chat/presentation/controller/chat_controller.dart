import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/deleteMessage.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/load_more_message.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/send_message.dart';
import 'package:riverpod_todo_app/features/chat/domain/usecases/stream_message.dart';
import 'package:riverpod_todo_app/features/chat/presentation/state/chat_state.dart';
import 'package:riverpod_todo_app/core/providers.dart';

import '../../domain/entities/chat_entity.dart';

final streamMessageProvider = Provider<StreamMessage>(
        (ref)=>sl<StreamMessage>()
);
final sendMessageProvider = Provider<SendMessage>(
        (ref)=>sl<SendMessage>()
);
final loadMoreMessageProvider = Provider<LoadMoreMessages>(
        (ref)=>sl<LoadMoreMessages>()
);
final deleteMessageProvider = Provider<DeleteMessage>(
        (ref)=>sl<DeleteMessage>()
);
class ChatParams {
  final String projectId;
  final String taskId;

  const ChatParams(this.projectId, this.taskId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatParams &&
              runtimeType == other.runtimeType &&
              projectId == other.projectId &&
              taskId == other.taskId;

  @override
  int get hashCode => Object.hash(projectId, taskId);
}


final chatControllerProvider = NotifierProvider.family.autoDispose<ChatController, ChatState, ChatParams>(
    ChatController.new
);
class ChatController extends AutoDisposeFamilyNotifier<ChatState, ChatParams>{
  late final StreamMessage _streamMessage;
  late final SendMessage _sendMessage;
  late final LoadMoreMessages _loadMoreMessages;
  late final DeleteMessage _deleteMessage;
  bool _isInitialized = false;
  StreamSubscription<List<Message>>? _subscription;

  @override
  ChatState build(ChatParams arg) {
    ref.keepAlive();
    final String projectId = arg.projectId;
    final String taskId = arg.taskId;

    _streamMessage = ref.read(streamMessageProvider);
    _sendMessage = ref.read(sendMessageProvider);
    _loadMoreMessages = ref.read(loadMoreMessageProvider);
    _deleteMessage = ref.read(deleteMessageProvider);

    if (!_isInitialized) {
      state = ChatState.loading();
      _setupStream(projectId, taskId);  // Tách ra method riêng
      _isInitialized = true;
    }

    ref.onDispose(() => _subscription?.cancel());
    return state;
  }

  void _setupStream(String projectId, String taskId) {
    // Cancel cũ nếu có (an toàn nếu rebuild)
    _subscription?.cancel();

    _subscription = _streamMessage(projectId, taskId).listen(
          (messages) {
            state = state.copyWith(
              messages: messages,
              isLoading: false,
              hasMore: messages.length == 30,
              error: null,
            );
          },
          onError: (e) {
            state = state.copyWith(
              error: e.toString(),
              isLoading: false,
            );
          },
    );
  }


  Future<void> sendMessage(String content, String uId) async{
    final String projectId = arg.projectId;
    final String taskId = arg.taskId;

    final Message message = Message(
        id: '',
        projectId: projectId,
        taskId: taskId,
        senderId: uId,
        type: MessageType.text,
        content: content,
        createdAt: DateTime.now()
    );

    await _sendMessage(message);

  }

  Future<void> deleteMessage(String messageId) async {
    final String projectId = arg.projectId;
    final String taskId = arg.taskId;

    await _deleteMessage(DeleteMessageParams(projectId, taskId, messageId));
  }

  // Future<void> loadMoreMessage() async {
  //   final String projectId = arg.projectId;
  //   final String taskId = arg.taskId;
  //
  //   final currentState = state;
  //   state = currentState.copyWith(isLoadingMore: true);
  //
  //   final data = await _loadMoreMessages(LoadMoreParams(projectId: projectId, taskId: taskId, lastMessage: currentState.messages.last));
  //
  //   data.fold(
  //       (failure) => state = currentState.copyWith(isLoadingMore: false, error: failure.message),
  //       (data) => state = currentState.copyWith(
  //         messages: [...currentState.messages, ...data],
  //         isLoadingMore: false,
  //         hasMore: data.isNotEmpty
  //       )
  //   );
  // }

}