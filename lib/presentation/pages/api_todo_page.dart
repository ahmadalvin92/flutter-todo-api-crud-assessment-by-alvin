import 'package:flutter/material.dart';

import '../../data/models/todo.dart';
import '../../data/repositories/todo_api_repository.dart';
import '../../data/services/todo_api_service.dart';
import '../controllers/api_todo_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/todo_card.dart';
import '../widgets/todo_form.dart';

class ApiTodoPage extends StatefulWidget {
  const ApiTodoPage({super.key});

  @override
  State<ApiTodoPage> createState() => _ApiTodoPageState();
}

class _ApiTodoPageState extends State<ApiTodoPage> {
  late final ApiTodoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ApiTodoController(TodoApiRepository(TodoApiService()))
      ..fetchTodos();
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
      key: const ValueKey('api-todo-page'),
      animation: _controller,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: _controller.fetchTodos,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Todo API',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data DummyJSON dengan state lokal setelah aksi.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _controller.isLoading
                        ? null
                        : _controller.fetchTodos,
                    tooltip: 'Muat ulang',
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TodoForm(
                    submitLabel: 'Tambah todo API',
                    onSubmit: (title, description) async {
                      final success = await _controller.addTodo(
                        title: title,
                        description: description,
                      );
                      if (!context.mounted) return success;
                      _showSnackBar(
                        context,
                        success
                            ? 'Todo API berhasil ditambahkan.'
                            : _controller.errorMessage ??
                                  'Todo API gagal ditambahkan.',
                      );
                      return success;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_controller.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_controller.errorMessage != null)
                EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Data belum tersedia',
                  message: _controller.errorMessage!,
                )
              else if (_controller.todos.isEmpty)
                const EmptyState(
                  icon: Icons.inbox_rounded,
                  title: 'Belum ada todo API',
                  message: 'Tarik untuk memuat ulang data dari API.',
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
              if (!_controller.isLoading && _controller.errorMessage == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _controller.hasMore
                      ? OutlinedButton.icon(
                          onPressed: _controller.isLoadingMore
                              ? null
                              : _controller.loadNextPage,
                          icon: _controller.isLoadingMore
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.expand_more_rounded),
                          label: Text(
                            _controller.isLoadingMore
                                ? 'Memuat data...'
                                : 'Muat berikutnya',
                          ),
                        )
                      : Text(
                          'Semua data sudah dimuat.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
            ],
          ),
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
          ? 'Status todo API diperbarui.'
          : _controller.errorMessage ?? 'Status API gagal diperbarui.',
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
                    ? 'Todo API berhasil diperbarui.'
                    : _controller.errorMessage ?? 'Todo API gagal diperbarui.',
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
          title: const Text('Hapus todo API?'),
          content: Text('Todo "${todo.title}" akan dihapus dari daftar.'),
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
          ? 'Todo API berhasil dihapus.'
          : _controller.errorMessage ?? 'Todo API gagal dihapus.',
    );
  }
}
