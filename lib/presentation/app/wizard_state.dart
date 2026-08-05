enum WizardStep { title, priority }

class AddTaskWizardState {
  final WizardStep step;
  final String draftTitle;

  const AddTaskWizardState({this.step = WizardStep.title, this.draftTitle = ''});

  AddTaskWizardState copyWith({WizardStep? step, String? draftTitle}) {
    return AddTaskWizardState(
      step: step ?? this.step,
      draftTitle: draftTitle ?? this.draftTitle,
    );
  }

  String get prompt => switch (step) {
    WizardStep.title =>
      'Étape 1/2 — Titre de la tâche (Entrée pour valider, Esc pour annuler) :',
    WizardStep.priority =>
      'Étape 2/2 — Priorité : low / medium / high (Entrée = medium) :',
  };
}