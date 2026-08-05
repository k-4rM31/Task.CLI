import 'dart:io';
// import 'package:dart_tui/dart_tui.dart';
// import 'package:task_cli/presentation/widgets/footet_widget.dart';
// import 'package:task_cli/presentation/widgets/header_widget.dart';

// String shortcutKey(List<String> keys) {
//   String keyBadge(String key) => '\x1B[100;97m $key \x1B[0m';
//   return keys.map(keyBadge).join('\x1B[2m + \x1B[0m');
// }

// String shortcutInstructionJustified(String label, List<String> keys, int shortcutContainerWidth) {
//   final shortcut = shortcutKey(keys);
//   final shortcutWidth = getWidth(shortcut);

//   final labelStyled = '\x1B[2m$label\x1B[0m';

//   final gap = shortcutContainerWidth - label.length - shortcutWidth;
//   final safeGap = gap > 1 ? gap : 1;

//   return labelStyled + (' ' * safeGap) + shortcut;
// }

// void main() async {
//   await Program(
//     options: const ProgramOptions(
//       altScreen: true, 
//       tickInterval: Duration(milliseconds: 530)
//     ),
//   ).run(FullscreenModel());
// }

// final class FullscreenModel extends TeaModel {
//   final TextInputModel textInput;
//   final CursorModel cursor;

//   static final shortcutList = [
//     ("Ajouter une nouvelle tâche", ["Ctrl", "N"]),
//     ("Modifier une tâche", ["Ctrl", "U"]),
//     ("Lister les tâches", ["Ctrl", "L"]),
//     ("Marquer une tâche comme terminée", ["Ctrl", "D"]),
//     ("Supprimer une tâche", ["Ctrl", "R"]),
//     ("Afficher l'aide", ["Ctrl", "H"]),
//     ("Quitter l'application", ["Ctrl", "C"]),
//   ];
  
//   FullscreenModel({ TextInputModel? textInput, CursorModel? cursor })
//     : textInput = textInput ??
//       TextInputModel(
//         placeholder: 'Type something…',
//         label: '>',
//         charLimit: 80,
//         validate: (value) => value.trim().isNotEmpty,
//         focused: true,
//         suggestions: ["help", "quit"]
//       ),
//     cursor = cursor ??
//       CursorModel(
//         mode: CursorMode.block,
//         blink: true,
//       );


//   @override
//   Cmd? init() => null;

//   @override
//   (Model, Cmd?) update(Msg msg) {
//     if (msg is KeyMsg && (msg.key == 'ctrl+c')) {
//       return (this, () => quit());
//     }

//     if (msg is WindowSizeMsg) {
//       return (this, null);
//     }
    
//     if (msg is TickMsg) {
//       final (updatedCursor, cursorCmd) = cursor.update(msg);
//       return (
//         FullscreenModel(textInput: textInput, cursor: updatedCursor as CursorModel),
//         cursorCmd,
//       );
//     } 

//     final (updatedTextInput, cmd) = textInput.update(msg);
//     return (
//       FullscreenModel(textInput: updatedTextInput as TextInputModel, cursor: cursor),
//       cmd,
//     );

//   }

//   @override
//   View view() {
//     // Recupérer la taille actuelle du terminal
//     final int width = stdout.hasTerminal ? stdout.terminalColumns : 80;
//     final int height = stdout.hasTerminal ? stdout.terminalLines : 24;

//     final buffer = StringBuffer();

//     // CONSTRUIRE LE HEADER
//     final (headerText, headerLines)  = HeaderWidget.build(width);
//     buffer.write(headerText);

//     // CONSTRUIRE LE BODY (HAUTEUR DYNAMIQUE)
//     // La hauteur du body = Hauteur totale - ligne header (ligne header = ligne name + ligne metadonnees + ligne metadonnees + 2 ligne de separation) - ligne footer
//     // final int headerLiness = buffer.toString().split('\n').length - 1;
//     const int footerLines = 3; // Ligne de separation + ligne footer
//     int bodyHeight = height - headerLines - footerLines;
//     if (bodyHeight < 0) bodyHeight = 0;
    

//     int sideMargin = (width * 0.3).round();
//     final int shortcutContainerWidth = width - (sideMargin * 2);

//     final List<String> shortcutView = [];
//     for (int i = 0; i < shortcutList.length; i++) {
//       final (label, keys) = shortcutList[i];
//       shortcutView.add(shortcutInstructionJustified(label, keys, shortcutContainerWidth));

//       if (i < shortcutList.length - 1) {
//         shortcutView.add(''); // ligne vide entre chaque raccourci, sauf après le dernier
//       }
//     }
    
//     final int blockStart = (bodyHeight - shortcutView.length) ~/ 2;

//     for (int i = 0; i < bodyHeight; i++) {
//       final int rowInBlock = i - blockStart;
//       if (rowInBlock >= 0 && rowInBlock < shortcutView.length) {
//         final currentLine = shortcutView[rowInBlock];
//         if (currentLine.isEmpty) {
//           buffer.writeln("".padRight(width));
//         } else {
//           buffer.writeln("${' ' * sideMargin} $currentLine ${' ' * sideMargin}");
//         }
//       } else {
//         buffer.writeln("".padRight(width));
//       }
//     }

//     // CONSTRUIRE LE FOOTER
//     String separatorLine = "".padRight(width, "─");
//     buffer.write(FooterWidget.build(width, separatorLine, textInput, cursor));

//     return newView(buffer.toString());
//   }
// }






import 'package:dart_tui/dart_tui.dart';

import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/usecases/add_task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';
import 'package:task_cli/domaine/usecases/toggle_task_done.dart';
import 'package:task_cli/domaine/usecases/delete_task.dart';
import 'package:task_cli/domaine/usecases/update_task_title.dart';
import 'package:task_cli/presentation/app/app_messages.dart';
import 'package:task_cli/presentation/app/wizard_state.dart';
import 'package:task_cli/presentation/widgets/header_widget.dart';
import 'package:task_cli/presentation/widgets/footet_widget.dart';
import 'package:task_cli/presentation/widgets/command_output_widget.dart';
import 'package:task_cli/presentation/screens/task_list_screen.dart';
import 'package:task_cli/presentation/commands/command.dart';
import 'package:task_cli/presentation/commands/command_parser.dart';

final class FullscreenModel extends TeaModel {
  final List<Task> tasks;
  final String? feedbackMessage;
  final bool feedbackSuccess;
  final AddTaskWizardState? wizard;
  final TextInputModel textInput;
  final CursorModel cursor;

  final AddTask addTaskUseCase;
  final ListTasks listTasksUseCase;
  final ToggleTaskDone toggleTaskDoneUseCase;
  final DeleteTask deleteTaskUseCase;
  final UpdateTaskTitle updateTaskTitleUseCase;

  FullscreenModel({
    required this.addTaskUseCase,
    required this.listTasksUseCase,
    required this.toggleTaskDoneUseCase,
    required this.deleteTaskUseCase,
    required this.updateTaskTitleUseCase,
    this.tasks = const [],
    this.feedbackMessage,
    this.feedbackSuccess = true,
    this.wizard,
    TextInputModel? textInput,
    CursorModel? cursor,
  })  : textInput = textInput ?? _freshTextInputStatic(),
        cursor = cursor ?? CursorModel(mode: CursorMode.block, blink: true);

  static TextInputModel _freshTextInputStatic() {
    return TextInputModel(
      placeholder: "Tape une commande…",
      label: '>',
      charLimit: 80,
      validate: (value) => value.trim().isNotEmpty,
      focused: true,
      suggestions: ["help", "list", "add", "done", "delete", "update", "quit"],
    );
  }

  TextInputModel _freshTextInput({
    String placeholder = 'Tape une commande…',
  }) => _freshTextInputStatic();

  FullscreenModel copyWith({
    List<Task>? tasks,
    String? feedbackMessage,
    bool clearFeedback = false,
    bool? feedbackSuccess,
    AddTaskWizardState? wizard,
    bool clearWizard = false,
    TextInputModel? textInput,
    CursorModel? cursor,
  }) {
    return FullscreenModel(
      addTaskUseCase: addTaskUseCase,
      listTasksUseCase: listTasksUseCase,
      toggleTaskDoneUseCase: toggleTaskDoneUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      updateTaskTitleUseCase: updateTaskTitleUseCase,
      tasks: tasks ?? this.tasks,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      feedbackSuccess: feedbackSuccess ?? this.feedbackSuccess,
      wizard: clearWizard ? null : (wizard ?? this.wizard),
      textInput: textInput ?? this.textInput,
      cursor: cursor ?? this.cursor,
    );
  }

  Cmd _loadTasksCmd() => () async {
    final result = await listTasksUseCase();
    return TasksLoadedMsg(result);
  };

  @override
  Cmd? init() => _loadTasksCmd();

  @override
  (Model, Cmd?) update(Msg msg) {
    if (msg is KeyMsg && msg.key == 'ctrl+c') {
      return (this, () => quit());
    }

    if (msg is TickMsg) {
      final (updatedCursor, cursorCmd) = cursor.update(msg);
      return (copyWith(cursor: updatedCursor as CursorModel), cursorCmd);
    }

    if (msg is TasksLoadedMsg) {
      return (copyWith(tasks: msg.tasks), null);
    }

    if (msg is CommandExecutedMsg) {
      return (
        copyWith(tasks: msg.tasks, feedbackMessage: msg.message, feedbackSuccess: msg.success),
        null,
      );
    }

    if (msg is CommandFeedbackMsg) {
      return (
        copyWith(feedbackMessage: msg.message, feedbackSuccess: msg.success),
        null,
      );
    }

    if (msg is KeyMsg && msg.key == 'ctrl+n' && wizard == null) {
      const newWizard = AddTaskWizardState();
      return (
        copyWith(
          wizard: newWizard,
          textInput: _freshTextInput(placeholder: newWizard.prompt),
          clearFeedback: true,
        ),
        null,
      );
    }

    if (msg is KeyMsg && msg.key == 'esc' && wizard != null) {
      return (
        copyWith(
          clearWizard: true,
          textInput: _freshTextInput(),
          feedbackMessage: 'Assistant annulé.',
          feedbackSuccess: false,
        ),
        null,
      );
    }

    if (msg is KeyMsg && msg.key == 'enter') {
      final text = textInput.value.trim();

      if (wizard != null) {
        final parsed = CommandParser.parse(text);
        if (parsed is! InvalidCommand) {
          // L'utilisateur a tapé une vraie commande : elle prend le dessus, le wizard est annulé.
          return copyWith(clearWizard: true)._dispatchCommand(parsed);
        }
        return _handleWizardInput(text);
      }

      return _dispatchCommand(CommandParser.parse(text));
    }

    if (msg is WindowSizeMsg) {
      return (this, null);
    }

    final (updatedTextInput, cmd) = textInput.update(msg);
    return (copyWith(textInput: updatedTextInput as TextInputModel), cmd);
  }

  (Model, Cmd?) _handleWizardInput(String text) {
    final w = wizard!;

    if (w.step == WizardStep.title) {
      if (text.isEmpty) {
        return (
          copyWith(
            feedbackMessage: 'Le titre ne peut pas être vide.',
            feedbackSuccess: false,
            textInput: _freshTextInput(placeholder: w.prompt),
          ),
          null,
        );
      }
      final nextWizard = w.copyWith(step: WizardStep.priority, draftTitle: text);
      return (
        copyWith(
          wizard: nextWizard,
          textInput: _freshTextInput(placeholder: nextWizard.prompt),
          clearFeedback: true,
        ),
        null,
      );
    }

    // step == WizardStep.priority
    Priority priority = Priority.medium;
    if (text.isNotEmpty) {
      final parsed = CommandParser.parsePriority(text);
      if (parsed == null) {
        return (
          copyWith(
            feedbackMessage: 'Priorité invalide: "$text" (low/medium/high)',
            feedbackSuccess: false,
            textInput: _freshTextInput(placeholder: w.prompt),
          ),
          null,
        );
      }
      priority = parsed;
    }

    final title = w.draftTitle;
    return (
      copyWith(clearWizard: true, textInput: _freshTextInput()),
      () async {
        await addTaskUseCase(title, priority: priority);
        final updated = await listTasksUseCase();
        return CommandExecutedMsg(success: true, message: 'Tâche ajoutée : "$title"', tasks: updated);
      },
    );
  }

  (Model, Cmd?) _dispatchCommand(Command cmd) {
    switch (cmd) {
      case AddCommand(:final title, :final priority):
        return (
          copyWith(textInput: _freshTextInput()),
          () async {
            await addTaskUseCase(title, priority: priority);
            final updated = await listTasksUseCase();
            return CommandExecutedMsg(success: true, message: 'Tâche ajoutée : "$title"', tasks: updated);
          },
        );

      case ListCommand():
        return (
          copyWith(textInput: _freshTextInput()),
          () async {
            final updated = await listTasksUseCase();
            return CommandExecutedMsg(success: true, message: 'Liste rafraîchie.', tasks: updated);
          },
        );

      case DoneCommand(:final index):
        if (index < 1 || index > tasks.length) {
          return (
            copyWith(textInput: _freshTextInput()),
            () async => CommandFeedbackMsg(
                  success: false,
                  message: 'Numéro invalide: $index (1-${tasks.length})',
                ),
          );
        }
        final id = tasks[index - 1].id;
        return (
          copyWith(textInput: _freshTextInput()),
          () async {
            await toggleTaskDoneUseCase(id);
            final updated = await listTasksUseCase();
            return CommandExecutedMsg(success: true, message: 'Tâche $index mise à jour.', tasks: updated);
          },
        );

      case DeleteCommand(:final index):
        if (index < 1 || index > tasks.length) {
          return (
            copyWith(textInput: _freshTextInput()),
            () async => CommandFeedbackMsg(
                  success: false,
                  message: 'Numéro invalide: $index (1-${tasks.length})',
                ),
          );
        }
        final id = tasks[index - 1].id;
        return (
          copyWith(textInput: _freshTextInput()),
          () async {
            await deleteTaskUseCase(id);
            final updated = await listTasksUseCase();
            return CommandExecutedMsg(success: true, message: 'Tâche $index supprimée.', tasks: updated);
          },
        );

      case UpdateCommand(:final index, :final newTitle):
        if (index < 1 || index > tasks.length) {
          return (
            copyWith(textInput: _freshTextInput()),
            () async => CommandFeedbackMsg(
                  success: false,
                  message: 'Numéro invalide: $index (1-${tasks.length})',
                ),
          );
        }
        final id = tasks[index - 1].id;
        return (
          copyWith(textInput: _freshTextInput()),
          () async {
            await updateTaskTitleUseCase(id, newTitle);
            final updated = await listTasksUseCase();
            return CommandExecutedMsg(success: true, message: 'Tâche $index renommée.', tasks: updated);
          },
        );

      case HelpCommand():
        return (
          copyWith(
            feedbackMessage:
                'Commandes: add "titre" [priorité] · list · done <n> · delete <n> · update <n> "titre" · quit  —  Ctrl+N: assistant guidé',
            feedbackSuccess: true,
            textInput: _freshTextInput(),
          ),
          null,
        );

      case QuitCommand():
        return (this, () => quit());

      case InvalidCommand(:final reason):
        return (
          copyWith(feedbackMessage: reason, feedbackSuccess: false, textInput: _freshTextInput()),
          null,
        );
      case PriorityCommand():
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  View view() {
    final int width = stdout.hasTerminal ? stdout.terminalColumns : 80;
    final int height = stdout.hasTerminal ? stdout.terminalLines : 24;
    final buffer = StringBuffer();

    final (headerText, headerLines) = HeaderWidget.build(width);
    buffer.write(headerText);

    const footerLines = 3;
    int bodyHeight = height - headerLines - footerLines;
    if (bodyHeight < 0) bodyHeight = 0;

    final topLines = CommandOutputWidget.build(
      width,
      feedbackMessage: feedbackMessage,
      feedbackSuccess: feedbackSuccess,
      wizardPrompt: wizard?.prompt,
    );

    final bodyLines = TaskListScreen.render(width, bodyHeight, tasks, topLines);
    for (final l in bodyLines) {
      buffer.writeln(l);
    }

    final separatorLine = "".padRight(width, "─");
    buffer.write(FooterWidget.build(width, separatorLine, textInput, cursor));

    return newView(buffer.toString());
  }
}