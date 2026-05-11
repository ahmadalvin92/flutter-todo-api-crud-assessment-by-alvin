import 'package:flutter/material.dart';

class LocalTodoPage extends StatelessWidget {
  const LocalTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const ValueKey('local-todo-page'),
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  color: theme.colorScheme.primary,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Fitur todo lokal akan aktif pada tahap berikutnya.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
