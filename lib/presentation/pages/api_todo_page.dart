import 'package:flutter/material.dart';

import '../../data/repositories/todo_api_repository.dart';
import '../../data/services/todo_api_service.dart';
import '../controllers/api_todo_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/todo_card.dart';

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
                    child: TodoCard(todo: todo),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
