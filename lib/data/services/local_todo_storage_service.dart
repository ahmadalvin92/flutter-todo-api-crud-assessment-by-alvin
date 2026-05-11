import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

class LocalTodoStorageService {
  static const _storageKey = 'todo_alvin_local_todos';

  Future<List<Todo>> getTodos() async {
    final preferences = await SharedPreferences.getInstance();
    final rawTodos = preferences.getStringList(_storageKey) ?? [];

    return rawTodos
        .map((rawTodo) => Todo.fromJson(jsonDecode(rawTodo)))
        .toList()
      ..sort(
        (first, second) => second.createdDate.compareTo(first.createdDate),
      );
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedTodos = todos
        .map((todo) => jsonEncode(todo.toJson()))
        .toList(growable: false);

    await preferences.setStringList(_storageKey, encodedTodos);
  }
}
