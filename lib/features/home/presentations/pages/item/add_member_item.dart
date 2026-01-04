import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/member_chip.dart';
import '../../controller/update_project_controller.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _controller = TextEditingController();

  bool _isLoading = false;
  String? _error;
  final List<MemberChip> _previewChip = [];

  Future<void> _search() async {
    final userId = _controller.text.trim();
    if (userId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final usecase = ref.read(getMemberChipsUseCaseProvider);
    final result = await usecase([userId]);

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

          if (chips.isEmpty) {
            _error = 'User not found';
            return;
          }

          final newChip = chips.first;

          final exists = _previewChip.any((c) => c.id == newChip.id);
          if (exists) {
            _error = 'User already added';
            return;
          }
          _previewChip.add(newChip);
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

          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _previewChip.map((chip) {
              return Chip(
                label: Text(chip.displayName),
                onDeleted: () {
                  setState(() {
                    _previewChip.remove(chip);
                  });
                },
              );
            }).toList(),
          )
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
