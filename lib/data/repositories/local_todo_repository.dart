import '../models/todo.dart';
import '../services/local_todo_storage_service.dart';

class LocalTodoRepository {
  LocalTodoRepository(this._storageService);

  final LocalTodoStorageService _storageService;

  Future<List<Todo>> getTodos() {
    return _storageService.getTodos();
  }

  Future<void> saveTodos(List<Todo> todos) {
    return _storageService.saveTodos(todos);
  }
}
