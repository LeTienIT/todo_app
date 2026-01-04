import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/features/chat/presentation/controller/chat_controller.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/chat_entity.dart';
class ChatPage extends ConsumerStatefulWidget {
  final String taskName;
  final String projectId;
  final String taskId;

  const ChatPage(
      this.taskName,
      this.projectId,
      this.taskId, {
        super.key,
      });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;
  int stt = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    stt++;

    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(
      chatControllerProvider(
        ChatParams(widget.projectId, widget.taskId),
      ),
    );
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: ${state.error}'),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  chatControllerProvider(
                    ChatParams(widget.projectId, widget.taskId),
                  ),
                );
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskName),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (state.messages.isEmpty && !state.isLoading)
                  const Center(
                    child: Text(
                      'Chưa có tin nhắn nào\nBắt đầu cuộc trò chuyện!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount:
                    state.messages.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      final reversedIndex = state.messages.length - 1 - index;

                      if (reversedIndex < 0) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final message = state.messages[index];

                      return MessageBubble(
                        message: message,
                        userId: authState.user!.id,
                      );
                    },
                  ),

                if (state.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                if (state.hasMore && state.messages.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Scroll lên để load thêm',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          _buildInput(authState),
        ],
      ),
    );
  }

  Widget _buildInput(authState) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _send(authState),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: () => _send(authState),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _send(authState) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(
      chatControllerProvider(
        ChatParams(widget.projectId, widget.taskId),
      ).notifier,
    ).sendMessage(text, authState.user!.id);

    _textController.clear();
    // _scrollController.animateTo(
    //   0,
    //   duration: const Duration(milliseconds: 300),
    //   curve: Curves.easeOut,
    // );
  }
}

class MessageBubble extends ConsumerWidget {
  final Message message;
  final String userId;  

  const MessageBubble({super.key, required this.message, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMe = message.senderId == userId;
    final senderName = message.senderName ?? "NoName";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: !isMe ? Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 16,  // Nhỏ gọn
              backgroundColor: _getAvatarColor(senderName),  // Màu random
              child: Text(
                _getInitials(senderName),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildMessageContent(context: context, ref:  ref),
              ),
            ),
          ],
        )
        : Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _buildMessageContent(isMe: true, context: context,ref: ref),
        ),
      ),
    );
  }

  Widget _buildMessageContent({required BuildContext context, required WidgetRef ref, bool isMe = false,}) {
    return GestureDetector(
      onLongPress: isMe ? () => _showDeleteMessageMenu(context, ref) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              fontSize: 10,
              color: isMe ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteMessageMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Xóa tin nhắn',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(
                chatControllerProvider(
                  ChatParams(message.projectId , message.taskId),
                ).notifier,
              ).deleteMessage(message.id);

            },
          ),
        );
      },
    );
  }
  
  String _getInitials(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';  // Chữ cái đầu
  }

  Color _getAvatarColor(String name) {
    final hash = name.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}