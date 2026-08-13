class TaskCliException implements Exception {
  final String message;

  const TaskCliException(this.message);

  @override
  String toString() => message;
}

class InvalidTaskException extends TaskCliException {
  const InvalidTaskException(super.message);
}

class TaskNotFoundException extends TaskCliException {
  const TaskNotFoundException(String id)
    : super('Aucune tache trouvee avec id: $id');
}

class StorageException extends TaskCliException {
  const StorageException(super.message);
}
