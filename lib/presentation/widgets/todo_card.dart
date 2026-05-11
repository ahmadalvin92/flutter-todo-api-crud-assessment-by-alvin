import 'package:flutter/material.dart';

import '../../data/models/todo.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    this.onToggleStatus,
    this.onEdit,
    this.onDelete,
  });

  final Todo todo;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = todo.isCompleted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: onToggleStatus,
              tooltip: isCompleted ? 'Tandai pending' : 'Tandai selesai',
              icon: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isCompleted
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todo.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<_TodoAction>(
              tooltip: 'Aksi todo',
              onSelected: (action) {
                switch (action) {
                  case _TodoAction.edit:
                    onEdit?.call();
                  case _TodoAction.delete:
                    onDelete?.call();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _TodoAction.edit,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_rounded),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: _TodoAction.delete,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline_rounded),
                    title: Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _TodoAction { edit, delete }
