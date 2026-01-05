import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../home/domain/entities/member_chip.dart';
import '../../../../home/presentations/controller/update_project_controller.dart';


class AddMemberDialogTask extends ConsumerStatefulWidget {
  const AddMemberDialogTask({super.key});

  @override
  ConsumerState<AddMemberDialogTask> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialogTask> {
  final _controller = TextEditingController();

  bool _isLoading = false;
  String? _error;
  MemberChip? _previewChip ;

  Future<void> _search() async {
    final userId = _controller.text.trim();
    if (userId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final usecase = ref.read(getMemberChipByNameUseCaseProvider);
    final result = await usecase(userId);

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (chips) {
        setState(() {
          _isLoading = false;
          _error = null;

          final newChip = chips;

          _previewChip = newChip;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter user ID',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _isLoading ? null : _search,
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_isLoading)
            const CircularProgressIndicator(),

          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),

          if(_previewChip != null)
            Chip(
                label: Text(_previewChip!.displayName),
                onDeleted: (){
                  setState(() {
                    _previewChip = null;
                  });
                },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _previewChip == null ? null : () => Navigator.pop(context, _previewChip),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
