import 'package:task_cli/domaine/entities/task.dart';
import 'package:test/test.dart';

void main() {
  group('Task entity', () {
    test('creates a StandardTask for low and medium priorities', () {
      final task = Task.create(
        id: '1',
        title: 'Read docs',
        priority: Priority.low,
      );

      expect(task, isA<StandardTask>());
      expect(task.type, 'standard');
      expect(task.requiresImmediateAttention, isFalse);
    });

    test('creates an UrgentTask for high priority', () {
      final task = Task.create(
        id: '1',
        title: 'Fix production',
        priority: Priority.high,
      );

      expect(task, isA<UrgentTask>());
      expect(task.type, 'urgent');
      expect(task.requiresImmediateAttention, isTrue);
      expect((task as UrgentTask).warningLabel, 'Urgent');
    });

    test('copyWith can transform a standard task into an urgent task', () {
      final task = Task.create(id: '1', title: 'Normal task');

      final updated = task.copyWith(priority: Priority.high);

      expect(updated, isA<UrgentTask>());
      expect(updated.priority, Priority.high);
    });
  });
}
