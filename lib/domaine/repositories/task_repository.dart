import 'package:task_cli/domaine/entities/task.dart';

abstract interface class TaskRepository {
  /// Recuperation de toutes les tâches stockees.
  Future<List<Task>> getAll();

  /// Ajout d'une nouvelle tâche.
  Future<void> add(Task task);

  /// Mise à jour d'une tâche existante (remplace celle avec le même id).
  Future<void> update(Task task);

  /// Suppression d'une tâche par son id.
  Future<void> delete(String id);
}