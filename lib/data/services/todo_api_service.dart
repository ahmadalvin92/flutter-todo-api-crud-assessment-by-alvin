import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_config.dart';
import '../models/todo_api_dto.dart';

class TodoApiService {
  TodoApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<TodoApiDto>> fetchTodos({
    required int limit,
    required int skip,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.todosPath}?limit=$limit&skip=$skip',
    );
    final response = await _client.get(uri);
    final body = _decodeResponse(response);
    final todos = body['todos'] as List<dynamic>? ?? [];

    return todos
        .map((item) => TodoApiDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TodoApiDto> createTodo(TodoApiDto dto) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.todosPath}/add');
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(dto.toCreateJson()),
    );

    return TodoApiDto.fromJson(_decodeResponse(response));
  }

  Future<TodoApiDto> updateTodo(TodoApiDto dto) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.todosPath}/${dto.id}',
    );
    final response = await _client.put(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(dto.toUpdateJson()),
    );

    return TodoApiDto.fromJson(_decodeResponse(response));
  }

  Future<void> deleteTodo(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.todosPath}/$id');
    final response = await _client.delete(uri);
    _decodeResponse(response);
  }

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TodoApiException(
        'API mengembalikan status ${response.statusCode}.',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class TodoApiException implements Exception {
  TodoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
