class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdDate,
  });

  final int id;
  final String title;
  final String description;
  final TodoStatus status;
  final DateTime createdDate;

  bool get isCompleted => status == TodoStatus.completed;

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    TodoStatus? status,
    DateTime? createdDate,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: _readInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: TodoStatusParser.fromValue(json['status'] ?? json['completed']),
      createdDate:
          DateTime.tryParse(json['createdDate']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

enum TodoStatus {
  pending('pending'),
  completed('completed');

  const TodoStatus(this.value);

  final String value;
}

class TodoStatusParser {
  static TodoStatus fromValue(Object? value) {
    if (value is bool) {
      return value ? TodoStatus.completed : TodoStatus.pending;
    }

    final normalized = value?.toString().toLowerCase();
    if (normalized == 'completed' || normalized == 'selesai') {
      return TodoStatus.completed;
    }

    return TodoStatus.pending;
  }
}
