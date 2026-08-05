enum Priority {
  low,
  medium,
  high;

  String get label => switch (this) {
    Priority.low => 'Basse',
    Priority.medium => 'Moyenne',
    Priority.high => 'Haute',
  };
}

class Task {
  final String id;
  final String title;
  final bool done;
  final Priority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id, 
    required this.title, 
    this.done = false, 
    this.priority = Priority.medium,
    required this.createdAt,
    required this.updatedAt
  });

  factory Task.create({
    required String id,
    required String title,
    Priority priority = Priority.medium,
  }) {
    final now = DateTime.now();
    return Task(id: id, title: title, priority: priority, createdAt: now, updatedAt: now);
  }

  Task copyWith({String? title, bool? done, Priority? priority, DateTime? updatedAt}) {
    return Task(
      id: id, 
      title: title ?? this.title, 
      done: done ?? this.done,
      priority: priority?? this.priority,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now()
    );
  }
}