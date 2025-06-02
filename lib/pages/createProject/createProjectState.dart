

import 'package:odc_mobile_template/business/models/domain/domain.dart';
import 'package:odc_mobile_template/business/models/project/createProject.dart';
import 'package:odc_mobile_template/business/models/project/roleSkill.dart';
import 'package:odc_mobile_template/business/models/role/role.dart';
import 'package:odc_mobile_template/business/models/skill/skill.dart';


class CreateProjectState {
  final CreateProject project;
  final List<Domain> availableDomains;
  final List<Role> availableRoles;
  final List<Skill> availableSkills;
  final List<String> newSkills;
  final List<RoleSkill> chosenRoles;
  final bool isLoading;
  final bool isSubmitting;
  final bool formSubmitted;
  final String? formError;
  final String? successMessage;

  CreateProjectState({
    required this.project,
    this.availableDomains = const [],
    this.availableRoles = const [],
    this.availableSkills = const [],
    this.newSkills = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.formSubmitted = false,
    this.formError,
    this.successMessage,
    this.chosenRoles = const []
  });

  /// Crée une copie de l'état avec les modifications spécifiées
  CreateProjectState copyWith({
    CreateProject? project,
    List<Domain>? availableDomains,
    List<Role>? availableRoles,
    List<Skill>? availableSkills,
    List<String>? newSkills,
    bool? isLoading,
    bool? isSubmitting,
    bool? formSubmitted,
    String? formError,
    String? successMessage,
    List<RoleSkill>? chosenRoles
  }) {
    return CreateProjectState(
      project: project ?? this.project,
      availableDomains: availableDomains ?? this.availableDomains,
      availableRoles: availableRoles ?? this.availableRoles,
      availableSkills: availableSkills ?? this.availableSkills,
      newSkills: newSkills ?? this.newSkills,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formSubmitted: formSubmitted ?? this.formSubmitted,
      formError: formError,
      successMessage: successMessage,
      chosenRoles: chosenRoles?? this.chosenRoles
    );
  }

  /// Crée un état initial avec des valeurs par défaut
  factory CreateProjectState.initial() {
    return CreateProjectState(
      project: CreateProject.empty(),
      newSkills: [],
      isLoading: true,
    );
  }

  /// Validation : au moins un domaine sélectionné
  bool get hasAtLeastOneDomain => project.domains.isNotEmpty;

  /// Validation : plage de dates valide
  bool get hasValidDateRange =>
      project.dateStart.isBefore(project.dateEnd) ||
          project.dateStart.isAtSameMomentAs(project.dateEnd);

  /// Validation : formulaire valide
  bool get isFormValid {
    return project.title.isNotEmpty &&
        project.description.isNotEmpty &&
        project.location.isNotEmpty &&
        project.budget >= 0 &&
        hasAtLeastOneDomain &&
        hasValidDateRange;
  }
}