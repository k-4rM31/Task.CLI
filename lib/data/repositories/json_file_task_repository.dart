import 'dart:convert';
import 'dart:io';

import 'package:task_cli/data/models/task_models.dart';
import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';

class JsonFileTaskRepository implements TaskRepository {
  final File _file;

  JsonFileTaskRepository(String path) : _file = File(path);

  Future<List<Map<String, dynamic>>> _readRaw() async {
    try {
      if (!await _file.exists()) return [];

      final content = await _file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content);
      if (decoded is! List) {
        throw const StorageException(
          'Le fichier JSON doit contenir une liste.',
        );
      }

      return decoded.cast<Map<String, dynamic>>();
    } on StorageException {
      rethrow;
    } on FormatException catch (error) {
      throw StorageException('JSON invalide: ${error.message}');
    } on FileSystemException catch (error) {
      throw StorageException('Erreur fichier: ${error.message}');
    }
  }

  Future<void> _writeRaw(List<Map<String, dynamic>> data) async {
    try {
      await _file.create(recursive: true);
      await _file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );
    } on FileSystemException catch (error) {
      throw StorageException('Erreur fichier: ${error.message}');
    }
  }

  @override
  Future<List<Task>> getAll() async {
    final raw = await _readRaw();
    return raw.map(TaskModel.fromJson).toList();
  }

  @override
  Future<void> add(Task task) async {
    final raw = await _readRaw();
    if (raw.any((item) => item['id'] == task.id)) {
      throw InvalidTaskException('Une tache existe deja avec id: ${task.id}');
    }
    raw.add(TaskModel.toJson(task));
    await _writeRaw(raw);
  }

  @override
  Future<void> update(Task task) async {
    final raw = await _readRaw();
    final index = raw.indexWhere((item) => item['id'] == task.id);
    if (index == -1) throw TaskNotFoundException(task.id);

    raw[index] = TaskModel.toJson(task);
    await _writeRaw(raw);
  }

  @override
  Future<void> delete(String id) async {
    final raw = await _readRaw();
    final initialLength = raw.length;
    raw.removeWhere((item) => item['id'] == id);
    if (raw.length == initialLength) throw TaskNotFoundException(id);

    await _writeRaw(raw);
  }
}
