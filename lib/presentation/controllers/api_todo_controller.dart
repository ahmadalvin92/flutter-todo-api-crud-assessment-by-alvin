import 'package:flutter/foundation.dart';

import '../../data/models/todo.dart';
import '../../data/repositories/todo_api_repository.dart';

class ApiTodoController extends ChangeNotifier {
  ApiTodoController(this._repository);

  final TodoApiRepository _repository;
  final List<Todo> _todos = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTodos() async {
    _setLoading(true);
    try {
      final todos = await _repository.fetchTodos();
      _todos
        ..clear()
        ..addAll(todos);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Data todo API belum bisa dimuat.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTodo({
    required String title,
    required String description,
  }) async {
    final draft = Todo(
      id: 0,
      title: title.trim(),
      description: description.trim(),
      status: TodoStatus.pending,
      createdDate: DateTime.now(),
    );

    try {
      final createdTodo = await _repository.createTodo(draft);
      _todos.insert(
        0,
        createdTodo.copyWith(
          title: draft.title,
          description: draft.description,
          createdDate: draft.createdDate,
        ),
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Todo API belum bisa ditambahkan.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTodo({
    required Todo todo,
    required String title,
    required String description,
  }) {
    return _sendUpdate(
      todo.copyWith(title: title.trim(), description: description.trim()),
    );
  }

  Future<bool> toggleStatus(Todo todo) {
    return _sendUpdate(
      todo.copyWith(
        status: todo.isCompleted ? TodoStatus.pending : TodoStatus.completed,
      ),
    );
  }

  Future<bool> deleteTodo(Todo todo) async {
    try {
      await _repository.deleteTodo(todo.id);
      _todos.removeWhere((item) => item.id == todo.id);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Todo API belum bisa dihapus.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _sendUpdate(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index == -1) return false;

    try {
      await _repository.updateTodo(updatedTodo);
      _todos[index] = updatedTodo;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Todo API belum bisa diperbarui.';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
