import 'package:flutter_test/flutter_test.dart';
import 'package:todo_alvin/data/models/todo.dart';

void main() {
  group('Todo model', () {
    test('fromJson membaca field todo dengan benar', () {
      final todo = Todo.fromJson({
        'id': 12,
        'title': 'Belajar Flutter',
        'description': 'Selesaikan technical test',
        'status': 'completed',
        'createdDate': '2026-05-11T10:00:00.000',
      });

      expect(todo.id, 12);
      expect(todo.title, 'Belajar Flutter');
      expect(todo.description, 'Selesaikan technical test');
      expect(todo.status, TodoStatus.completed);
      expect(todo.createdDate, DateTime.parse('2026-05-11T10:00:00.000'));
    });

    test('toJson mengubah todo menjadi map yang konsisten', () {
      final createdDate = DateTime.parse('2026-05-11T10:00:00.000');
      final todo = Todo(
        id: 8,
        title: 'Rapikan UI',
        description: 'Buat tampilan nyaman di Android',
        status: TodoStatus.pending,
        createdDate: createdDate,
      );

      expect(todo.toJson(), {
        'id': 8,
        'title': 'Rapikan UI',
        'description': 'Buat tampilan nyaman di Android',
        'status': 'pending',
        'createdDate': createdDate.toIso8601String(),
      });
    });

    test('parser status mendukung nilai boolean dari API', () {
      expect(TodoStatusParser.fromValue(true), TodoStatus.completed);
      expect(TodoStatusParser.fromValue(false), TodoStatus.pending);
    });
  });
}
