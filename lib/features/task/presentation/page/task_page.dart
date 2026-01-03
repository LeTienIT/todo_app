import 'package:flutter/material.dart';
import '../../../home/domain/entities/project.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/task_controller.dart';
import '../state/task_state.dart';
import 'item/project_header_item.dart';
import 'package:go_router/go_router.dart';
class TaskPage extends ConsumerWidget {
  final Project project;

  const TaskPage({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskControllerProvider(project.id!));

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Column(
        children: [
          ProjectHeader(project: project),
          const Divider(height: 1),
          Expanded(
            child: _buildTaskBody(project.id!, taskState, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateTaskSheet(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskBody(String projectID, TaskState taskState, WidgetRef ref) {
    return switch (taskState) {
      TaskInitial() => const Center(
        child: Text('Đang khởi tạo ứng dụng...'),
      ),

      TaskLoading() => const Center(
        child: CircularProgressIndicator(),
      ),

      TaskLoaded(:final tasks) => tasks.isEmpty ? const Center(
        child: Text(
          'Chưa có task nào\nNhấn nút + để thêm task đầu tiên',
          textAlign: TextAlign.center,
        ),
      )
      : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isDone = task.isDone;

          return Dismissible(
            key: Key(task.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Xóa',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa task?'),
                  content: Text('Bạn có chắc muốn xóa task "${task.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              ref.read(taskControllerProvider(projectID).notifier).deleteTask(task.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted")));
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onLongPress: () {

                },
                onTap: (){
                  context.push('/chat/$projectID/${task.id}/${Uri.encodeComponent(task.title)}');
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Checkbox(
                    value: isDone,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(taskControllerProvider(project.id!).notifier).toggleTask(task.id, value);
                      }
                    },
                    shape: const CircleBorder(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assignee: ${task.assigneeId ?? "All"}'),
                      Text(
                        "Message: ${task.lastMessage ?? ""} ",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                  trailing: isDone
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
              ),
            ),
          );
        },
      ),

    // Case Error
      TaskError(:final message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $message'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(taskControllerProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    };
  }
  void _showCreateTaskSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final assigneeController = TextEditingController(); // Nếu có assignee

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thêm Task Mới',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề task',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: assigneeController,
                  decoration: const InputDecoration(
                    labelText: 'Giao cho (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      // Gọi controller để tạo task
                      ref.read(taskControllerProvider(project.id!).notifier).createTask(
                        title: title,
                        assigneeId: assigneeController.text.isEmpty ? null : assigneeController.text.trim(),
                      );

                      Navigator.pop(context); // Đóng modal
                    },
                    child: const Text('Thêm Task'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


