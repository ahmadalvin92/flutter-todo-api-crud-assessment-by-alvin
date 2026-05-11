import 'package:flutter/foundation.dart';

import '../../data/models/todo.dart';
import '../../data/repositories/local_todo_repository.dart';

class LocalTodoController extends ChangeNotifier {
  LocalTodoController(this._repository);

  final LocalTodoRepository _repository;
  final List<Todo> _todos = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTodos() async {
    _setLoading(true);
    try {
      _todos
        ..clear()
        ..addAll(await _repository.getTodos());
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Todo lokal belum bisa dimuat.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTodo({
    required String title,
    required String description,
  }) async {
    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch,
      title: title.trim(),
      description: description.trim(),
      status: TodoStatus.pending,
      createdDate: DateTime.now(),
    );

    try {
      _todos.insert(0, todo);
      await _repository.saveTodos(_todos);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _todos.removeWhere((item) => item.id == todo.id);
      _errorMessage = 'Todo belum bisa disimpan.';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
