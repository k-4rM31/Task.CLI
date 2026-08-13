enum Priority {
  low,
  medium,
  high;

  String get label => switch (this) {
    Priority.low => 'Basse',
    Priority.medium => 'Moyenne',
    Priority.high => 'Haute',
  };

  int get sortRank => switch (this) {
    Priority.high => 0,
    Priority.medium => 1,
    Priority.low => 2,
  };
}

abstract class Task {
  final String id;
  final String title;
  final bool done;
  final Priority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.done = false,
    this.priority = Priority.medium,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.create({
    required String id,
    required String title,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) {
    final now = DateTime.now();
    return _TaskFactory.createConcreteTask(
      id: id,
      title: title,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Task.restore({
    required String id,
    required String title,
    bool done = false,
    Priority priority = Priority.medium,
    DateTime? dueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return _TaskFactory.createConcreteTask(
      id: id,
      title: title,
      done: done,
      priority: priority,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get type;

  bool get requiresImmediateAttention;

  bool get isOverdue =>
      dueDate != null && !done && dueDate!.isBefore(DateTime.now());

  Task copyWith({
    String? title,
    bool? done,
    Priority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? updatedAt,
  });
}

class StandardTask extends Task {
  const StandardTask({
    required super.id,
    required super.title,
    super.done,
    super.priority,
    super.dueDate,
    required super.createdAt,
    required super.updatedAt,
  });

  @override
  String get type => 'standard';

  @override
  bool get requiresImmediateAttention => isOverdue;

  @override
  Task copyWith({
    String? title,
    bool? done,
    Priority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? updatedAt,
  }) {
    return _TaskFactory.createConcreteTask(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class UrgentTask extends Task {
  const UrgentTask({
    required super.id,
    required super.title,
    super.done,
    super.dueDate,
    required super.createdAt,
    required super.updatedAt,
  }) : super(priority: Priority.high);

  String get warningLabel => 'Urgent';

  @override
  String get type => 'urgent';

  @override
  bool get requiresImmediateAttention => !done;

  @override
  Task copyWith({
    String? title,
    bool? done,
    Priority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? updatedAt,
  }) {
    return _TaskFactory.createConcreteTask(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class _TaskFactory {
  static Task createConcreteTask({
    required String id,
    required String title,
    bool done = false,
    Priority priority = Priority.medium,
    DateTime? dueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final normalizedTitle = title.trim();
    if (priority == Priority.high) {
      return UrgentTask(
        id: id,
        title: normalizedTitle,
        done: done,
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    return StandardTask(
      id: id,
      title: normalizedTitle,
      done: done,
      priority: priority,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
