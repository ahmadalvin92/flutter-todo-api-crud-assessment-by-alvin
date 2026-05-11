import 'package:flutter/material.dart';

import '../../data/models/todo.dart';
import '../../data/repositories/local_todo_repository.dart';
import '../../data/services/local_todo_storage_service.dart';
import '../controllers/local_todo_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/todo_card.dart';
import '../widgets/todo_form.dart';

class LocalTodoPage extends StatefulWidget {
  const LocalTodoPage({super.key});

  @override
  State<LocalTodoPage> createState() => _LocalTodoPageState();
}

class _LocalTodoPageState extends State<LocalTodoPage> {
  late final LocalTodoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalTodoController(
      LocalTodoRepository(LocalTodoStorageService()),
    )..loadTodos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      key: const ValueKey('local-todo-page'),
      animation: _controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Todo Lokal',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Catatan harian tersimpan langsung di perangkat.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TodoForm(
                  submitLabel: 'Tambah todo',
                  onSubmit: (title, description) async {
                    final success = await _controller.addTodo(
                      title: title,
                      description: description,
                    );
                    if (!context.mounted) return success;
                    _showSnackBar(
                      context,
                      success
                          ? 'Todo berhasil ditambahkan.'
                          : _controller.errorMessage ?? 'Todo gagal disimpan.',
                    );
                    return success;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_controller.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_controller.todos.isEmpty)
              const EmptyState(
                icon: Icons.inbox_rounded,
                title: 'Belum ada todo',
                message: 'Tambahkan todo pertama untuk mulai mengatur tugas.',
              )
            else
              ..._controller.todos.map(
                (todo) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TodoCard(
                    todo: todo,
                    onToggleStatus: () => _toggleStatus(todo),
                    onEdit: () => _showEditSheet(todo),
                    onDelete: () => _confirmDelete(todo),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleStatus(Todo todo) async {
    final success = await _controller.toggleStatus(todo);
    if (!mounted) return;
    _showSnackBar(
      context,
      success
          ? 'Status todo diperbarui.'
          : _controller.errorMessage ?? 'Status gagal diperbarui.',
    );
  }

  Future<void> _showEditSheet(Todo todo) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: TodoForm(
            initialTitle: todo.title,
            initialDescription: todo.description,
            submitLabel: 'Simpan perubahan',
            onSubmit: (title, description) async {
              final success = await _controller.updateTodo(
                todo: todo,
                title: title,
                description: description,
              );
              if (!mounted || !sheetContext.mounted) return success;
              if (success) Navigator.of(sheetContext).pop();
              _showSnackBar(
                context,
                success
                    ? 'Todo berhasil diperbarui.'
                    : _controller.errorMessage ?? 'Todo gagal diperbarui.',
              );
              return success;
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus todo?'),
          content: Text('Todo "${todo.title}" akan dihapus dari perangkat.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    final success = await _controller.deleteTodo(todo);
    if (!mounted) return;
    _showSnackBar(
      context,
      success
          ? 'Todo berhasil dihapus.'
          : _controller.errorMessage ?? 'Todo gagal dihapus.',
    );
  }
}
