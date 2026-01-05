import 'package:flutter/material.dart';
import 'package:riverpod_todo_app/features/task/domain/enities/task.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../home/domain/entities/member_chip.dart';
import '../../../home/domain/entities/project.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentations/controller/update_project_controller.dart';
import '../controller/task_controller.dart';
import '../state/task_state.dart';
import 'item/add_member_item.dart';
import 'item/project_header_item.dart';
import 'package:go_router/go_router.dart';

enum TaskFilter { all, assigned }

class TaskPage extends ConsumerStatefulWidget {
  final Project project;

  const TaskPage({super.key, required this.project});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TaskPage();
  }

}

class _TaskPage extends ConsumerState<TaskPage>{
  MemberChip? assaigneeChip;
  TaskFilter _currentFilter = TaskFilter.all;


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final taskState = ref.watch(taskControllerProvider(widget.project.id!));
    final currentUserId = authState.user!.id;

    return Scaffold(
      appBar: AppBar(title: Text("Tasks")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= 800;
          final double maxWidth = isTablet ? 700 : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  ProjectHeader(project: widget.project),
                  const Divider(height: 1),
                  Expanded(
                    child: _buildTaskBody(widget.project.id!, taskState, ref, currentUserId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateTaskSheet(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterButton(TaskFilter filter, String label) {
    final isSelected = _currentFilter == filter;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currentFilter = filter;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskBody(String projectID, TaskState taskState, WidgetRef ref, String currentUserId) {
    return switch (taskState) {
      TaskInitial() => const Center(
        child: Text('Đang khởi tạo ứng dụng...'),
      ),
      TaskLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      TaskLoaded(:final tasks) => _buildLoadedTasks(tasks, projectID, ref, currentUserId),
      TaskError(:final message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $message'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(taskControllerProvider(widget.project.id!)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    };
  }

  Widget _buildLoadedTasks(List<TaskEntity> tasks, String projectID, WidgetRef ref, String currentUserId) {
    final filteredTasks = _currentFilter == TaskFilter.all
        ? tasks
        : tasks.where((task) => task.assigneeId == currentUserId).toList();

    return Column(
      children: [
        // Row với 2 nút filter
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFilterButton(TaskFilter.all, 'Tất cả'),
              _buildFilterButton(TaskFilter.assigned, 'Đã giao'),
            ],
          ),
        ),
        Expanded(
          child: filteredTasks.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.task_alt_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  _currentFilter == TaskFilter.all
                      ? 'Chưa có task nào'
                      : 'Chưa có task nào được giao cho bạn',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentFilter == TaskFilter.all
                      ? 'Nhấn nút + để thêm task đầu tiên'
                      : 'Tạo hoặc chờ giao task để bắt đầu',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              final isDone = task.isDone;
              Future<MemberChip?> fetchMemberChip() async {
                if (task.assigneeId == null) return null;
                final usecase = ref.read(getMemberChipsUseCaseProvider);
                final rs = await usecase([task.assigneeId!]);
                final MemberChip result = rs.fold(
                      (failure) {
                    return MemberChip("", "All");
                  },
                      (chips) {
                    return chips.first;
                  },
                );
                return result;
              }
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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã xóa")),
                    );
                  }
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onLongPress: () {
                      _showUpdateTaskSheet(task, context, ref);
                    },
                    onTap: () {
                      context.push('/chat/$projectID/${task.id}/${Uri.encodeComponent(task.title)}');
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Checkbox(
                        value: isDone,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(taskControllerProvider(widget.project.id!).notifier)
                                .toggleTask(task.id, value);
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
                          FutureBuilder<MemberChip?>(
                            future: fetchMemberChip(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Assignee: Đang tải...');
                              } else if (snapshot.hasError) {
                                return Text('Assignee: ${task.assigneeId ?? "All"} (Lỗi)');
                              } else if (snapshot.hasData && snapshot.data != null) {
                                final memberChip = snapshot.data!;
                                return Text('Assignee: ${memberChip.displayName}');
                              } else {
                                return const Text('Assignee: ---');
                              }
                            },
                          ),
                          Text(
                            "Message: ${task.lastMessage ?? ""} ",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                      trailing: isDone ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateTaskSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();

    bool isLoadingMembers = false;
    String? currentMemberIds;
    MemberChip? memberChips;
    String? loadError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      'New Task',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Members',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    setModalState(() {  // Dùng setModalState để loading
                                      isLoadingMembers = true;
                                    });
                                    final result = await showDialog<MemberChip?>(
                                      context: context,
                                      builder: (_) => AddMemberDialogTask(),
                                    );

                                    if (result != null) {
                                      setModalState(() {
                                        isLoadingMembers = false;
                                        currentMemberIds = result.id;
                                        memberChips = result;
                                        loadError = null;
                                      });
                                    } else {
                                      setModalState(() {
                                        isLoadingMembers = false;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildMembers(
                              isLoadingMembers: isLoadingMembers,
                              loadError: loadError,
                              memberChips: memberChips,
                              onRemoveMember: () {
                                setModalState(() {
                                  memberChips = null;
                                  currentMemberIds = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          ref.read(taskControllerProvider(widget.project.id!).notifier).createTask(
                            title: title,
                            assigneeId: currentMemberIds?.trim(),
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
      },
    );
  }

  void _showUpdateTaskSheet(TaskEntity task, BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: task.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FutureBuilder<MemberChip?>(
          future: _loadInitialMemberChip(task.assigneeId, ref),
          builder: (context, initialSnapshot) {
            bool isLoadingMembers = false;
            MemberChip? memberChips = initialSnapshot.data;
            String? loadError = initialSnapshot.hasError ? 'Error loading assignee' : null;

            return StatefulBuilder(
              builder: (context, setModalState) {
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
                          'Edit Task',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Members',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        setModalState(() {
                                          isLoadingMembers = true;
                                        });
                                        final result = await showDialog<MemberChip?>(
                                          context: context,
                                          builder: (_) => AddMemberDialogTask(),
                                        );

                                        if (result != null) {
                                          setModalState(() {
                                            isLoadingMembers = false;
                                            memberChips = result;
                                            loadError = null;
                                          });
                                        } else {
                                          setModalState(() {
                                            isLoadingMembers = false;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Add'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildMembers(
                                  isLoadingMembers: isLoadingMembers,
                                  loadError: loadError,
                                  memberChips: memberChips,
                                  onRemoveMember: () {
                                    setModalState(() {
                                      memberChips = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final title = titleController.text.trim();
                              if (title.isEmpty) return;

                              ref.read(taskControllerProvider(widget.project.id!).notifier).updateTask(
                                task: TaskEntity(
                                    id: task.id,
                                    title: titleController.text.trim(),
                                    isDone: task.isDone,
                                    createdAt: task.createdAt,
                                    assigneeId: memberChips?.id
                                )
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Updated")));
                            },
                            child: const Text('Update Task'),  // Fix text
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMembers({required bool isLoadingMembers, required String? loadError, required MemberChip? memberChips, required VoidCallback onRemoveMember,}) {
    if (isLoadingMembers) {
      return const CircularProgressIndicator();
    }

    if (loadError != null) {
      return Text('Error: $loadError');
    }

    if (memberChips != null) {
      return Chip(
        label: Text(memberChips.displayName),
        onDeleted: onRemoveMember,  // Truyền callback để xóa
      );
    } else {
      return const SizedBox();
    }
  }

  Future<MemberChip?> _loadInitialMemberChip(String? assigneeId, WidgetRef ref) async {
    if (assigneeId == null || assigneeId.isEmpty) return null;

    final usecase = ref.read(getMemberChipsUseCaseProvider);
    final rs = await usecase([assigneeId]);

    final MemberChip? result = rs.fold(
          (failure) {
        debugPrint("Load initial member error: $failure");
        return null;
      },
          (chips) {
        if (chips.isNotEmpty) {
          return chips.first;
        }
        return null;
      },
    );
    return result;
  }

}


