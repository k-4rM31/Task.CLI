# Task.CLI

Task.CLI est une application en ligne de commande ecrite en Dart pour gerer une liste de taches locale.

## Fonctionnalites

- Ajouter une tache avec un titre, une priorite (`low`, `medium`, `high`) et une date limite optionnelle.
- Lister les taches, avec tri optionnel par priorite ou par date limite.
- Marquer une tache comme terminee.
- Supprimer une tache.
- Persister les donnees dans un fichier JSON local (`tasks.json`).

## Choix techniques

- Architecture separee entre domaine, donnees et presentation.
- `Task` est une classe abstraite, avec heritage via `StandardTask` et `UrgentTask`.
- `TaskRepository` implemente l'interface generique `Repository<Task>`.
- Les erreurs metier utilisent des exceptions personnalisees (`InvalidTaskException`, `TaskNotFoundException`, `StorageException`).
- Les tests unitaires utilisent le package `test`.

## Installation

```bash
dart pub get
```

## Lancer l'application

```bash
dart run
```

L'application stocke les taches dans un fichier `tasks.json` cree dans le dossier depuis lequel la commande est lancee.

## Commandes disponibles

```text
add "titre" [low|medium|high] [YYYY-MM-DD]
list
list priority
list date
done <numero>
delete <numero>
update <numero> "nouveau titre" [low|medium|high] [YYYY-MM-DD]
priority <numero> <low|medium|high>
help
quit
```

Exemples:

```text
add "Preparer la demo" high 2026-08-20
add "Lire la documentation" low
list priority
list date
done 1
delete 2
```

## Lancer les tests

```bash
dart test
```

## Analyse statique

```bash
dart analyze
```
