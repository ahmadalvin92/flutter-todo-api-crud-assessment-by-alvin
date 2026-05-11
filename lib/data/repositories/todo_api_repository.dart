import '../../core/constants/api_config.dart';
import '../models/todo.dart';
import '../models/todo_api_dto.dart';
import '../services/todo_api_service.dart';

class TodoApiRepository {
  TodoApiRepository(this._service);

  final TodoApiService _service;

  Future<List<Todo>> fetchTodos({
    int limit = ApiConfig.defaultLimit,
    int skip = 0,
  }) async {
    final dtos = await _service.fetchTodos(limit: limit, skip: skip);
    return dtos.map((dto) => dto.toTodo()).toList();
  }

  Future<Todo> createTodo(Todo todo) async {
    final createdTodo = await _service.createTodo(TodoApiDto.fromTodo(todo));
    return createdTodo.toTodo();
  }

  Future<Todo> updateTodo(Todo todo) async {
    final updatedTodo = await _service.updateTodo(TodoApiDto.fromTodo(todo));
    return updatedTodo.toTodo();
  }

  Future<void> deleteTodo(int id) {
    return _service.deleteTodo(id);
  }
}
