enum WizardStep { title, priority }

class AddTaskWizardState {
  final WizardStep step;
  final String draftTitle;

  const AddTaskWizardState({
    this.step = WizardStep.title,
    this.draftTitle = '',
  });

  AddTaskWizardState copyWith({WizardStep? step, String? draftTitle}) {
    return AddTaskWizardState(
      step: step ?? this.step,
      draftTitle: draftTitle ?? this.draftTitle,
    );
  }

  String get prompt => switch (step) {
    WizardStep.title =>
      'Etape 1/2 - Titre de la tache (Entree pour valider, Esc pour annuler) :',
    WizardStep.priority =>
      'Etape 2/2 - Priorite : low / medium / high (Entree = medium) :',
  };
}
