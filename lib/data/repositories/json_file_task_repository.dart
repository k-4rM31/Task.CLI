import 'dart:convert';
import 'dart:io';

import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/data/models/task_models.dart';
import 'package:task_cli/domaine/repositories/task_repository.dart';



class JsonFileTaskRepository implements TaskRepository {
  final File _file;

  JsonFileTaskRepository(String path) : _file = File(path);

  /// Lire le fichier et retourne la liste brute de Maps JSON.
  /// Si le fichier n'existe pas encore ou est vide, retourne une liste vide.
  Future<List<Map<String, dynamic>>> _readRaw() async {
    if (!await _file.exists()) return []; // si fichier n'existe pas, retourne une liste vide

    final content = await _file.readAsString();
    if (content.trim().isEmpty) return []; // si le fichier existe mais son contenus est vide, retourne une liste vide

    final decoded = jsonDecode(content) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Écrit la liste de Maps JSON dans le fichier (créé si besoin).
  Future<void> _writeRaw(List<Map<String, dynamic>> data) async {
    await _file.create(recursive: true);
    await _file.writeAsString(jsonEncode(data));
  }

  @override
  Future<List<Task>> getAll() async {
    final raw = await _readRaw();
    return raw.map(TaskModel.fromJson).toList();
  }

  @override
  Future<void> add(Task task) async {
    final raw = await _readRaw();
    raw.add(TaskModel.toJson(task));
    await _writeRaw(raw);
  }

  @override
  Future<void> update(Task task) async {
    final raw = await _readRaw();
    final index = raw.indexWhere((m) => m['id'] == task.id);
    if (index != -1) {
      raw[index] = TaskModel.toJson(task);
    }
    await _writeRaw(raw);
  }

  @override
  Future<void> delete(String id) async {
    final raw = await _readRaw();
    raw.removeWhere((m) => m['id'] == id);
    await _writeRaw(raw);
  }
}