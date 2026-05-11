import 'todo.dart';

class TodoApiDto {
  const TodoApiDto({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  final int id;
  final String todo;
  final bool completed;
  final int userId;

  factory TodoApiDto.fromJson(Map<String, dynamic> json) {
    return TodoApiDto(
      id: _readInt(json['id']),
      todo: json['todo']?.toString() ?? json['title']?.toString() ?? '',
      completed:
          json['completed'] == true ||
          json['status']?.toString().toLowerCase() == 'completed',
      userId: _readInt(json['userId']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'todo': todo,
      'completed': completed,
      'userId': userId == 0 ? 1 : userId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {'todo': todo, 'completed': completed};
  }

  Todo toTodo() {
    return Todo(
      id: id,
      title: todo,
      description:
          'Todo dari DummyJSON untuk user ${userId == 0 ? 1 : userId}.',
      status: completed ? TodoStatus.completed : TodoStatus.pending,
      createdDate: DateTime.now(),
    );
  }

  static TodoApiDto fromTodo(Todo todo) {
    return TodoApiDto(
      id: todo.id,
      todo: todo.title,
      completed: todo.isCompleted,
      userId: 1,
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
