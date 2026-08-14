import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/repositories/repository.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class InMemoryRepository<T> implements Repository<T> {
  final String Function(T) idOf;
  final List<T> _items = [];

  InMemoryRepository(this.idOf);

  @override
  Future<List<T>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> add(T item) async {
    if (_items.any((i) => idOf(i) == idOf(item))) {
      throw InvalidTaskException('Élément déjà existant');
    }
    _items.add(item);
  }

  @override
  Future<void> update(T item) async {
    final index = _items.indexWhere((i) => idOf(i) == idOf(item));
    if (index == -1) throw TaskNotFoundException(idOf(item));
    _items[index] = item;
  }

  @override
  Future<void> delete(String id) async {
    final before = _items.length;
    _items.removeWhere((i) => idOf(i) == id);
    if (_items.length == before) throw TaskNotFoundException(id);
  }
}

class InMemoryTaskRepository extends InMemoryRepository<Task>
    implements TaskRepository {
  InMemoryTaskRepository() : super((t) => t.id);
}