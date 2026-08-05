import 'package:dart_tui/dart_tui.dart';
import 'package:task_cli/data/repositories/json_file_task_repository.dart';
import 'package:task_cli/domaine/usecases/add_task.dart';
import 'package:task_cli/domaine/usecases/list_tasks.dart';
import 'package:task_cli/domaine/usecases/toggle_task_done.dart';
import 'package:task_cli/domaine/usecases/delete_task.dart';
import 'package:task_cli/domaine/usecases/update_task_title.dart';
import 'package:task_cli/task_cli.dart';

void main() async {
  final repository = JsonFileTaskRepository('tasks.json');

  await Program(
    options: const ProgramOptions(
      altScreen: true,
      tickInterval: Duration(milliseconds: 530),
    ),
  ).run(FullscreenModel(
    addTaskUseCase: AddTask(repository),
    listTasksUseCase: ListTasks(repository),
    toggleTaskDoneUseCase: ToggleTaskDone(repository),
    deleteTaskUseCase: DeleteTask(repository),
    updateTaskTitleUseCase: UpdateTaskTitle(repository),
  ));
}