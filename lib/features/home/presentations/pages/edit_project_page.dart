import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/features/home/domain/entities/project.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_todo_app/features/home/presentations/controller/update_project_controller.dart';
import 'package:riverpod_todo_app/features/home/presentations/state/update_project_state.dart';

import '../../domain/entities/member_chip.dart';
import 'item/add_member_item.dart';

class EditProjectPage extends ConsumerStatefulWidget {
  final Project project;
  const EditProjectPage({super.key, required this.project});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EditProjectPage();
  }

}
class _EditProjectPage extends ConsumerState<EditProjectPage>{
  late List<String> _currentMemberIds;
  List<MemberChip> _memberChips = [];
  bool _isLoadingMembers = true;
  String? _loadError;
  late final TextEditingController nameController;
  late final TextEditingController deadlineController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.project.name);
    deadlineController = TextEditingController(text: widget.project.deadline.toLocal().toString().split(' ')[0],);
    _currentMemberIds = List.from(widget.project.members);

    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final usecase = ref.read(getMemberChipsUseCaseProvider);
      final result = await usecase(_currentMemberIds);

      result.fold(
        (failure) {
          setState(() {
            _loadError = failure.message;
            _isLoadingMembers = false;
          });
        },
        (chips) {
          setState(() {
            _memberChips = chips;
            _isLoadingMembers = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoadingMembers = false;
      });
    }
  }

  void _onSave() {
    final updatedProject = widget.project.copyWith(
      members: _currentMemberIds,
      name: nameController.text,
      deadline: DateTime.parse(deadlineController.text),
    );
    
    ref.read(updateProjectControllerProvider.notifier).updateProject(updatedProject);
  }
  
  @override
  Widget build(BuildContext context) {
    ref.listen<UpdateProjectState>(
      updateProjectControllerProvider, (previous, next) {
        if (next is UpdateProjectSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Update success')),
          );
        }

        if (next is UpdateProjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.message)),
          );
        }
      },
    );
    final state = ref.watch(updateProjectControllerProvider);
    final isLoading = state is UpdateProjectLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: deadlineController,
                      decoration: const InputDecoration(
                        labelText: 'Deadline',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: widget.project.deadline,
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          deadlineController.text = date.toLocal().toString().split(' ')[0];
                        }
                      },
                    ),
                    // Bỏ creator
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

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
                            final result = await showDialog<List<MemberChip>?>(
                              context: context,
                              builder: (_) => AddMemberDialog(),
                            );

                            if (result != null && result.isNotEmpty) {
                              setState(() {
                                for (final chip in result) {
                                  if (_currentMemberIds.contains(chip.id)) continue;
                                  _currentMemberIds.add(chip.id);
                                  _memberChips.add(chip);
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _buildMembers(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _onSave,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text(
                    'Save',
                    key: ValueKey('text'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMembers(){
    if (_isLoadingMembers) {
      return const CircularProgressIndicator();
    }

    if (_loadError != null) {
      return Text('Error: $_loadError');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _memberChips.map((chip) {
        return Chip(
          label: Text(chip.displayName),
          onDeleted: () => _removeMember(chip),
        );
      }).toList(),
    );
  }
  
  void _removeMember(MemberChip chip) {
    setState(() {
      _memberChips.removeWhere((c) => c.id == chip.id);
      _currentMemberIds.remove(chip.id);
    });
  }
}