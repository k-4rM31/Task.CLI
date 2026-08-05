import 'package:task_cli/domaine/entities/task.dart';

class TaskModel {
  /// Convertit une Task (de lib/domaine/entities) en Map serialisable en JSON.
  static Map<String, dynamic> toJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'done': task.done,
      'priority': task.priority.name,
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
    };
  }

  /// Reconstruit une Task à partir d'une Map issue du JSON.
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      done: json['done'] as bool,
      priority: Priority.values.byName(json['priority'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}