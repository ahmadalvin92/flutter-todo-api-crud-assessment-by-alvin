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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
