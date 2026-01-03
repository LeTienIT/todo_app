import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class StreamMessage{
  final MessageRepository messageRepository;

  StreamMessage(this.messageRepository);

  Stream<List<Message>> call(String projectId, String taskId){
    return messageRepository.streamMessage(projectId, taskId);
  }
}