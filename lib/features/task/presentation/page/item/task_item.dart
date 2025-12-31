import 'package:flutter/material.dart';

import '../../../domain/enities/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/task_controller.dart';

class TaskItem extends ConsumerWidget {
  final TaskEntity task;
  final String projectId;

  const TaskItem({super.key, required this.projectId, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: CheckboxListTile(
        value: task.isDone,
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
            task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        onChanged: (value) {
          ref.read(taskControllerProvider(projectId).notifier).toggleTask(task.id, !task.isDone);
        },
      ),
    );
  }
}
