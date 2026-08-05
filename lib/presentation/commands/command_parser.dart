import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/presentation/commands/command.dart';

class CommandParser {
  // Liste officielle des verbes supportés et leurs alias
  static const _validVerbs = {
    'add', 
    'done', 
    'delete', 'del', 'rm', 
    'update', 'edit', 
    'priority', 'chpri', 
    'list', 'ls', 
    'help', '?', 
    'quit', 'exit', 'q'
  };

  static List<String> _tokenize(String input) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < input.length && input[i + 1] != ' ') {
          throw const FormatException('Syntaxe invalide : Espace requis après un guillemet fermant.');
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
      throw const FormatException('Syntaxe invalide : Guillemet (") non fermé.');
    }

    if (buffer.isNotEmpty) tokens.add(buffer.toString());
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

  static Command parse(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return const InvalidCommand('Syntaxe invalide : Commande vide.');

    try {
      final tokens = _tokenize(input);
      final verb = tokens.first.toLowerCase();
      final args = tokens.skip(1).toList();
      print('DEBUG: verb="$verb", args=$args'); // Debugging line

      // Validation stricte du Verbe
      if (!_validVerbs.contains(verb)) {
        return InvalidCommand('Commande inconnue : "$verb" (Taper "help" pour voir la liste)');
      }

      // Validation de la syntaxe selon le pattern du verbe
      switch (verb) {
        case 'add':
          if (args.isEmpty) {
            return const InvalidCommand('Syntaxe invalide. Usage: add "<titre>" [<priorité>]');
          }
          final title = args[0];
          Priority priority = Priority.medium;
          if (args.length > 1) {
            final parsed = parsePriority(args[1]);
            if (parsed == null) return InvalidCommand('Syntaxe invalide : Priorité "${args[1]}" inconnue.');
            priority = parsed;
          }
          return AddCommand(title, priority);

        case 'done':
          if (args.isEmpty) return const InvalidCommand('Syntaxe invalide. Usage: done <numéro>');
          final index = int.tryParse(args[0]);
          if (index == null) return InvalidCommand('Syntaxe invalide : "$args" n\'est pas un numéro valide.');
          return DoneCommand(index);

        case 'delete' || 'del' || 'rm':
          if (args.isEmpty) return const InvalidCommand('Syntaxe invalide. Usage: delete <numéro>');
          final index = int.tryParse(args[0]);
          if (index == null) return InvalidCommand('Syntaxe invalide : "$args" n\'est pas un numéro valide.');
          return DeleteCommand(index);

        case 'update' || 'edit':
          if (args.length < 2) {
            return const InvalidCommand('Syntaxe invalide. Usage: update <numéro> "<nouveau_titre>" [<priorité>]');
          }
          final index = int.tryParse(args[0]);
          if (index == null) return InvalidCommand('Syntaxe invalide : "$args" n\'est pas un numéro valide.');
          
          final newTitle = args[1];
          Priority? newPriority;
          if (args.length > 2) {
            final parsed = parsePriority(args[2]);
            if (parsed == null) return InvalidCommand('Syntaxe invalide : Priorité "${args[2]}" inconnue.');
            newPriority = parsed;
          }
          return UpdateCommand(index, newTitle, newPriority);

        case 'priority' || 'chpri':
          if (args.length < 2) {
            return const InvalidCommand('Syntaxe invalide. Usage: priority <numéro> <priorité>');
          }
          final String index = args[0];
          // if (index == null) return InvalidCommand('Syntaxe invalide : "$args" n\'est pas un numéro valide.');
          
          final parsedPriority = parsePriority(args[1]);
          if (parsedPriority == null) return InvalidCommand('Syntaxe invalide : Priorité "${args[1]}" inconnue.');
          return PriorityCommand(index, parsedPriority);

        case 'list' || 'ls':
          if (args.isNotEmpty) return const InvalidCommand('Syntaxe invalide. Usage: list (ne prend pas d\'arguments)');
          return const ListCommand();

        case 'help' || '?':
          return const HelpCommand();

        case 'quit' || 'exit' || 'q':
          return const QuitCommand();
          
        default:
          return InvalidCommand('Commande inconnue : "$verb"');
      }
    } on FormatException catch (e) {
      // Capturée depuis _tokenize (ex: guillemet non fermé)
      return InvalidCommand(e.message);
    }
  }
}
