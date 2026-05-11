import 'package:flutter/foundation.dart';

import '../../data/models/todo.dart';
import '../../data/repositories/local_todo_repository.dart';

class LocalTodoController extends ChangeNotifier {
  LocalTodoController(this._repository);

  final LocalTodoRepository _repository;
  final List<Todo> _todos = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  TodoFilter _filter = TodoFilter.all;

  List<Todo> get todos => List.unmodifiable(_todos);
  List<Todo> get visibleTodos {
    return _todos.where((todo) {
      final matchesSearch = todo.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesFilter = switch (_filter) {
        TodoFilter.all => true,
        TodoFilter.completed => todo.isCompleted,
        TodoFilter.pending => !todo.isCompleted,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TodoFilter get filter => _filter;

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

  Future<bool> updateTodo({
    required Todo todo,
    required String title,
    required String description,
  }) {
    return _replaceTodo(
      todo.copyWith(title: title.trim(), description: description.trim()),
    );
  }

  Future<bool> toggleStatus(Todo todo) {
    return _replaceTodo(
      todo.copyWith(
        status: todo.isCompleted ? TodoStatus.pending : TodoStatus.completed,
      ),
    );
  }

  Future<bool> deleteTodo(Todo todo) async {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index == -1) return false;

    final removedTodo = _todos.removeAt(index);
    try {
      await _repository.saveTodos(_todos);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _todos.insert(index, removedTodo);
      _errorMessage = 'Todo belum bisa dihapus.';
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }

  void setFilter(TodoFilter value) {
    _filter = value;
    notifyListeners();
  }

  Future<bool> _replaceTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index == -1) return false;

    final oldTodo = _todos[index];
    _todos[index] = updatedTodo;
    try {
      await _repository.saveTodos(_todos);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      _todos[index] = oldTodo;
      _errorMessage = 'Todo belum bisa diperbarui.';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

enum TodoFilter {
  all('Semua'),
  completed('Selesai'),
  pending('Pending');

  const TodoFilter(this.label);

  final String label;
}
