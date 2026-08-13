import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';
import 'package:task_cli/presentation/commands/command.dart';

class CommandParser {
  static const _validVerbs = {
    'add',
    'done',
    'delete',
    'del',
    'rm',
    'update',
    'edit',
    'priority',
    'chpri',
    'list',
    'ls',
    'help',
    '?',
    'quit',
    'exit',
    'q',
  };

  static List<String> _tokenize(String input) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      if (char == '"') {
        if (inQuotes && i + 1 < input.length && input[i + 1] != ' ') {
          throw const FormatException(
            'Syntaxe invalide : espace requis apres un guillemet fermant.',
          );
        }
        inQuotes = !inQuotes;
        continue;
      }

      if (char == ' ' && !inQuotes) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        continue;
      }
      buffer.write(char);
    }

    if (inQuotes) {
      throw const FormatException('Syntaxe invalide : guillemet non ferme.');
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }
    return tokens;
  }

  static Priority? parsePriority(String raw) {
    return switch (raw.toLowerCase()) {
      'low' || 'basse' => Priority.low,
      'medium' || 'moyenne' => Priority.medium,
      'high' || 'haute' => Priority.high,
      _ => null,
    };
  }

  static DateTime? parseDueDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static TaskSort? parseSort(String raw) {
    return switch (raw.toLowerCase()) {
      'priority' || 'priorite' => TaskSort.priority,
      'date' || 'due' || 'deadline' => TaskSort.dueDate,
      _ => null,
    };
  }

  static Command parse(String raw) {
    final input = raw.trim();
    if (input.isEmpty) {
      return const InvalidCommand('Syntaxe invalide : commande vide.');
    }

    try {
      final tokens = _tokenize(input);
      final verb = tokens.first.toLowerCase();
      final args = tokens.skip(1).toList();

      if (!_validVerbs.contains(verb)) {
        return InvalidCommand(
          'Commande inconnue : "$verb" (taper "help" pour voir la liste)',
        );
      }

      switch (verb) {
        case 'add':
          return _parseAdd(args);
        case 'done':
          return _parseIndexedCommand(
            args,
            usage: 'Usage: done <numero>',
            build: DoneCommand.new,
          );
        case 'delete' || 'del' || 'rm':
          return _parseIndexedCommand(
            args,
            usage: 'Usage: delete <numero>',
            build: DeleteCommand.new,
          );
        case 'update' || 'edit':
          return _parseUpdate(args);
        case 'priority' || 'chpri':
          return _parsePriorityCommand(args);
        case 'list' || 'ls':
          return _parseList(args);
        case 'help' || '?':
          return const HelpCommand();
        case 'quit' || 'exit' || 'q':
          return const QuitCommand();
        default:
          return InvalidCommand('Commande inconnue : "$verb"');
      }
    } on FormatException catch (error) {
      return InvalidCommand(error.message);
    }
  }

  static Command _parseAdd(List<String> args) {
    if (args.isEmpty) {
      return const InvalidCommand(
        'Usage: add "titre" [low|medium|high] [YYYY-MM-DD]',
      );
    }

    final title = args[0];
    var priority = Priority.medium;
    DateTime? dueDate;

    if (args.length > 1) {
      final parsedPriority = parsePriority(args[1]);
      final parsedDate = parseDueDate(args[1]);
      if (parsedPriority != null) {
        priority = parsedPriority;
      } else if (parsedDate != null) {
        dueDate = parsedDate;
      } else {
        return InvalidCommand('Priorite ou date invalide : "${args[1]}".');
      }
    }

    if (args.length > 2) {
      dueDate = parseDueDate(args[2]);
      if (dueDate == null) {
        return InvalidCommand('Date invalide : "${args[2]}".');
      }
    }

    if (args.length > 3) {
      return const InvalidCommand(
        'Usage: add "titre" [low|medium|high] [YYYY-MM-DD]',
      );
    }

    return AddCommand(title, priority, dueDate: dueDate);
  }

  static Command _parseIndexedCommand(
    List<String> args, {
    required String usage,
    required Command Function(int index) build,
  }) {
    if (args.isEmpty) {
      return InvalidCommand(usage);
    }

    final index = int.tryParse(args[0]);
    if (index == null) {
      return InvalidCommand('Numero invalide : "${args[0]}".');
    }

    return build(index);
  }

  static Command _parseUpdate(List<String> args) {
    if (args.length < 2) {
      return const InvalidCommand(
        'Usage: update <numero> "nouveau titre" [priorite] [YYYY-MM-DD]',
      );
    }

    final index = int.tryParse(args[0]);
    if (index == null) {
      return InvalidCommand('Numero invalide : "${args[0]}".');
    }

    final newTitle = args[1];
    Priority? newPriority;
    DateTime? newDueDate;

    if (args.length > 2) {
      newPriority = parsePriority(args[2]);
      if (newPriority == null) {
        return InvalidCommand('Priorite invalide : "${args[2]}".');
      }
    }

    if (args.length > 3) {
      newDueDate = parseDueDate(args[3]);
      if (newDueDate == null) {
        return InvalidCommand('Date invalide : "${args[3]}".');
      }
    }

    if (args.length > 4) {
      return const InvalidCommand(
        'Usage: update <numero> "nouveau titre" [priorite] [YYYY-MM-DD]',
      );
    }

    return UpdateCommand(index, newTitle, newPriority, newDueDate: newDueDate);
  }

  static Command _parsePriorityCommand(List<String> args) {
    if (args.length < 2) {
      return const InvalidCommand('Usage: priority <numero> <priorite>');
    }

    final index = int.tryParse(args[0]);
    if (index == null) {
      return InvalidCommand('Numero invalide : "${args[0]}".');
    }

    final priority = parsePriority(args[1]);
    if (priority == null) {
      return InvalidCommand('Priorite invalide : "${args[1]}".');
    }

    return PriorityCommand(index, priority);
  }

  static Command _parseList(List<String> args) {
    if (args.isEmpty) {
      return const ListCommand();
    }

    if (args.length > 1) {
      return const InvalidCommand('Usage: list [priority|date]');
    }

    final sort = parseSort(args[0]);
    if (sort == null) {
      return InvalidCommand('Tri inconnu : "${args[0]}".');
    }

    return ListCommand(sort: sort);
  }
}
