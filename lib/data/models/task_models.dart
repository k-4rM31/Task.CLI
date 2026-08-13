import 'package:task_cli/domaine/entities/task.dart';

class TaskModel {
  static Map<String, dynamic> toJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'done': task.done,
      'priority': task.priority.name,
      'dueDate': task.dueDate?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task.build(
      id: json['id'] as String,
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
      priority: Priority.values.byName(json['priority'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
