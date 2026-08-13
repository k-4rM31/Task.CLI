import 'dart:io';

import 'package:dart_tui/dart_tui.dart';
import 'package:task_cli/domaine/entities/task.dart';
import 'package:task_cli/domaine/exceptions/task_cli_exception.dart';
import 'package:task_cli/domaine/usecases/add_task.dart';
import 'package:task_cli/domaine/usecases/delete_task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';
import 'package:task_cli/domaine/usecases/toggle_task_done.dart';
import 'package:task_cli/domaine/usecases/update_task_title.dart';
import 'package:task_cli/presentation/app/app_messages.dart';
import 'package:task_cli/presentation/app/wizard_state.dart';
import 'package:task_cli/presentation/commands/command.dart';
import 'package:task_cli/presentation/commands/command_parser.dart';
import 'package:task_cli/presentation/screens/task_list_screen.dart';
import 'package:task_cli/presentation/widgets/command_output_widget.dart';
import 'package:task_cli/presentation/widgets/footet_widget.dart';
import 'package:task_cli/presentation/widgets/header_widget.dart';

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
  }) : textInput = textInput ?? _freshTextInputStatic(),
       cursor = cursor ?? CursorModel(mode: CursorMode.block, blink: true);

  static TextInputModel _freshTextInputStatic({
    String placeholder = 'Tape une commande...',
  }) {
    return TextInputModel(
      placeholder: placeholder,
      label: '>',
      charLimit: 100,
      validate: (value) => value.trim().isNotEmpty,
      focused: true,
      suggestions: const [
        'help',
        'list',
        'list priority',
        'list date',
        'add',
        'done',
        'delete',
        'update',
        'quit',
      ],
    );
  }

  TextInputModel _freshTextInput({
    String placeholder = 'Tape une commande...',
  }) {
    return _freshTextInputStatic(placeholder: placeholder);
  }

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
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      feedbackSuccess: feedbackSuccess ?? this.feedbackSuccess,
      wizard: clearWizard ? null : (wizard ?? this.wizard),
      textInput: textInput ?? this.textInput,
      cursor: cursor ?? this.cursor,
    );
  }

  Cmd _loadTasksCmd({TaskSort sort = TaskSort.none}) => () async {
    try {
      final result = await listTasksUseCase(sort: sort);
      return TasksLoadedMsg(result);
    } on TaskCliException catch (error) {
      return CommandFeedbackMsg(success: false, message: error.message);
    }
  };

  Cmd _execute(String message, Future<void> Function() action) => () async {
    try {
      await action();
      final updated = await listTasksUseCase();
      return CommandExecutedMsg(
        success: true,
        message: message,
        tasks: updated,
      );
    } on TaskCliException catch (error) {
      return CommandFeedbackMsg(success: false, message: error.message);
    }
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
        copyWith(
          tasks: msg.tasks,
          feedbackMessage: msg.message,
          feedbackSuccess: msg.success,
        ),
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
          feedbackMessage: 'Assistant annule.',
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
    final currentWizard = wizard!;

    if (currentWizard.step == WizardStep.title) {
      if (text.isEmpty) {
        return (
          copyWith(
            feedbackMessage: 'Le titre ne peut pas etre vide.',
            feedbackSuccess: false,
            textInput: _freshTextInput(placeholder: currentWizard.prompt),
          ),
          null,
        );
      }
      final nextWizard = currentWizard.copyWith(
        step: WizardStep.priority,
        draftTitle: text,
      );
      return (
        copyWith(
          wizard: nextWizard,
          textInput: _freshTextInput(placeholder: nextWizard.prompt),
          clearFeedback: true,
        ),
        null,
      );
    }

    var priority = Priority.medium;
    if (text.isNotEmpty) {
      final parsed = CommandParser.parsePriority(text);
      if (parsed == null) {
        return (
          copyWith(
            feedbackMessage: 'Priorite invalide: "$text" (low/medium/high)',
            feedbackSuccess: false,
            textInput: _freshTextInput(placeholder: currentWizard.prompt),
          ),
          null,
        );
      }
      priority = parsed;
    }

    final title = currentWizard.draftTitle;
    return (
      copyWith(clearWizard: true, textInput: _freshTextInput()),
      _execute(
        'Tache ajoutee : "$title"',
        () => addTaskUseCase(title, priority: priority),
      ),
    );
  }

  (Model, Cmd?) _dispatchCommand(Command cmd) {
    switch (cmd) {
      case AddCommand(:final title, :final priority, :final dueDate):
        return (
          copyWith(textInput: _freshTextInput()),
          _execute(
            'Tache ajoutee : "$title"',
            () => addTaskUseCase(title, priority: priority, dueDate: dueDate),
          ),
        );

      case ListCommand(:final sort):
        return (
          copyWith(textInput: _freshTextInput()),
          () async {
            try {
              final updated = await listTasksUseCase(sort: sort);
              return CommandExecutedMsg(
                success: true,
                message: 'Liste rafraichie.',
                tasks: updated,
              );
            } on TaskCliException catch (error) {
              return CommandFeedbackMsg(success: false, message: error.message);
            }
          },
        );

      case DoneCommand(:final index):
        final invalid = _validateIndex(index);
        if (invalid != null) return invalid;
        final id = tasks[index - 1].id;
        return (
          copyWith(textInput: _freshTextInput()),
          _execute(
            'Tache $index mise a jour.',
            () => toggleTaskDoneUseCase(id),
          ),
        );

      case DeleteCommand(:final index):
        final invalid = _validateIndex(index);
        if (invalid != null) return invalid;
        final id = tasks[index - 1].id;
        return (
          copyWith(textInput: _freshTextInput()),
          _execute('Tache $index supprimee.', () => deleteTaskUseCase(id)),
        );

      case UpdateCommand(
        :final index,
        :final newTitle,
        :final newPriority,
        :final newDueDate,
      ):
        final invalid = _validateIndex(index);
        if (invalid != null) return invalid;
        final id = tasks[index - 1].id;
        return (
          copyWith(textInput: _freshTextInput()),
          _execute(
            'Tache $index renommee.',
            () => updateTaskTitleUseCase(
              id,
              newTitle,
              priority: newPriority,
              dueDate: newDueDate,
            ),
          ),
        );

      case PriorityCommand(:final index, :final priority):
        final invalid = _validateIndex(index);
        if (invalid != null) return invalid;
        final task = tasks[index - 1];
        return (
          copyWith(textInput: _freshTextInput()),
          _execute(
            'Priorite de la tache $index mise a jour.',
            () =>
                updateTaskTitleUseCase(task.id, task.title, priority: priority),
          ),
        );

      case HelpCommand():
        return (
          copyWith(
            feedbackMessage:
                'Commandes: add "titre" [priorite] [YYYY-MM-DD] | list [priority|date] | done <n> | delete <n> | update <n> "titre" [priorite] [YYYY-MM-DD] | quit',
            feedbackSuccess: true,
            textInput: _freshTextInput(),
          ),
          null,
        );

      case QuitCommand():
        return (this, () => quit());

      case InvalidCommand(:final reason):
        return (
          copyWith(
            feedbackMessage: reason,
            feedbackSuccess: false,
            textInput: _freshTextInput(),
          ),
          null,
        );
    }
  }

  (Model, Cmd?)? _validateIndex(int index) {
    if (index >= 1 && index <= tasks.length) return null;
    return (
      copyWith(textInput: _freshTextInput()),
      () async => CommandFeedbackMsg(
        success: false,
        message: 'Numero invalide: $index (1-${tasks.length})',
      ),
    );
  }

  @override
  View view() {
    final width = stdout.hasTerminal ? stdout.terminalColumns : 80;
    final height = stdout.hasTerminal ? stdout.terminalLines : 24;
    final buffer = StringBuffer();

    final (headerText, headerLines) = HeaderWidget.build(width);
    buffer.write(headerText);

    const footerLines = 3;
    var bodyHeight = height - headerLines - footerLines;
    if (bodyHeight < 0) bodyHeight = 0;

    final topLines = CommandOutputWidget.build(
      width,
      feedbackMessage: feedbackMessage,
      feedbackSuccess: feedbackSuccess,
      wizardPrompt: wizard?.prompt,
    );

    final bodyLines = TaskListScreen.render(width, bodyHeight, tasks, topLines);
    for (final line in bodyLines) {
      buffer.writeln(line);
    }

    final separatorLine = ''.padRight(width, '-');
    buffer.write(FooterWidget.build(width, separatorLine, textInput, cursor));

    return newView(buffer.toString());
  }
}
