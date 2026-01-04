import 'package:flutter/material.dart';
import 'package:riverpod_todo_app/shared/menu_share.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../controller/project_controller.dart';
import '../state/project_state.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HonePage();
  }

}
class _HonePage extends ConsumerState<HomePage>{
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final projectState = ref.watch(projectControllerProvider);

    ref.listen<ProjectState>(projectControllerProvider, (prev, next) {
      if (next is CreatedProject) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm project")));
        context.push(
          '/project/${next.p.id}',
          extra: next.p,
        );
      }

    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        centerTitle: true,
      ),
      drawer: MenuShared(user: authState.user),
      body: _buildProjectBody(projectState, authState.user?.id),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectSheet(context, ref, authState.user!.id),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectBody(ProjectState state, String? userId) {
    return switch (state) {
      ProjectInitial() || ProjectLoading() || CreatedProject() => const Center(
        child: CircularProgressIndicator(),
      ),
      ProjectLoaded(:final projects) => _buildLoadedBody(projects),
      ProjectError(:final message) => Center(child: Text(message)),
    };
  }

  Widget _buildLoadedBody(List<Project> projects) {
    final filteredProjects = _searchQuery.isEmpty ? projects : projects.where((project) => project.name.toLowerCase().contains(_searchQuery)).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm dự án theo tên...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        Expanded(
          child: filteredProjects.isEmpty ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  _searchQuery.isEmpty ? 'Chưa có dự án nào' : 'Không tìm thấy dự án nào',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn nút + để tạo dự án đầu tiên',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'Thử tìm kiếm với từ khóa khác',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          )
          : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredProjects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              final deadline = project.deadline;
              final formattedDate =
                  '${deadline.day.toString().padLeft(2, '0')}/${deadline.month.toString().padLeft(2, '0')}/${deadline.year}';

              return Dismissible(
                key: Key(project.id!),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.delete_forever,
                          color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Xóa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Xóa dự án?'),
                      content: Text(
                          'Bạn có chắc muốn xóa dự án "${project.name}"?\n'
                              'Tất cả task bên trong cũng sẽ bị xóa.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Xóa',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  ref.read(projectControllerProvider.notifier)
                      .deleteProject(project.id!);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa')),
                    );
                  }
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.push('/project/${project.id}',
                          extra: project);
                    },
                    onLongPress: () {
                      context.push('/editProject', extra: project);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon màu project (nếu có field color)
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.folder,
                                color: Colors.red, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Members: ${project.members.length} • Deadline: $formattedDate',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.grey[400], size: 18),
                        ],
                      ),
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

  void _showCreateProjectSheet(BuildContext context, WidgetRef ref, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: _CreateProjectForm(ref: ref, uid: uid,),
        );
      },
    );
  }
}
class _CreateProjectForm extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String uid;
  const _CreateProjectForm({required this.ref, required this.uid});

  @override
  ConsumerState<_CreateProjectForm> createState() =>
      _CreateProjectFormState();
}

class _CreateProjectFormState extends ConsumerState<_CreateProjectForm> {

  final _nameController = TextEditingController();
  DateTime? _deadline;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(projectControllerProvider) is ProjectLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create Project',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Project name',
          ),
        ),
        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() => _deadline = picked);
            }
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(
            _deadline == null
                ? 'Pick deadline'
                : _deadline!.toLocal().toString().split(' ')[0],
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
            if (_nameController.text.isEmpty || _deadline == null) {
              return;
            }

            widget.ref
                .read(projectControllerProvider.notifier)
                .createProject(
              _nameController.text,
              [widget.uid],
              _deadline!,
              widget.uid,
            );

            Navigator.pop(context);
          },
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Create'),
        ),
      ],
    );
  }
}


