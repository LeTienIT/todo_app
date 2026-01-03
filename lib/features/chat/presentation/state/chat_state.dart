import '../../domain/entities/chat_entity.dart';
import 'package:equatable/equatable.dart';

class ChatState extends Equatable {
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ChatState({  // Thêm const cho immutable
    required this.messages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
  });

  factory ChatState.initial() => const ChatState(
    messages: [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: false,
  );

  factory ChatState.loading() => const ChatState(  // Mới: Để set loading rõ
    messages: [],
    isLoading: true,
    isLoadingMore: false,
    hasMore: false,
  );

  factory ChatState.error(String err) => ChatState(  // Mới: Error state
    messages: const [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: false,
    error: err,
  );

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,  // Fix: Giữ error cũ nếu không pass (tránh clear nhầm)
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, isLoadingMore, hasMore, error];  // Fix: Đầy đủ
}
