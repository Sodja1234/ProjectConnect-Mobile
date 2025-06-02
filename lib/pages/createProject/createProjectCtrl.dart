import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/domain/domainNetworkService.dart';
import 'package:odc_mobile_template/business/services/project/projectNetworkService.dart';
import 'package:odc_mobile_template/business/models/project/createProject.dart';
import 'package:odc_mobile_template/business/models/project/roleSkill.dart';

import 'package:odc_mobile_template/business/services/role/roleNetworkService.dart';
import 'package:odc_mobile_template/business/services/skill/skillNetworkService.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectState.dart';

import '../../../main.dart';


/// Contrôleur pour la gestion du formulaire de création de projet
class CreateProjectCtrl extends StateNotifier<CreateProjectState> {
  final ProjectNetworkService _projectService = getIt<ProjectNetworkService>();
  final roleService = getIt<RoleNetworkService>();
  final domainService=getIt<DomainNetworkService>();
  final skillService=getIt<SkillNetworkService>();

  CreateProjectCtrl() : super(CreateProjectState.initial()) {
    // Déplacer l'initialisation après la construction du widget

  }

  /// Charge les données initiales nécessaires au formulaire
  void _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true);
      // Appels API pour récupérer les données
      final domains = await domainService.getDomains();
      final roles = await roleService.getRoles();
      final skills = await skillService.getSkill();



      // Initialiser les dates avec la date actuelle
      final now = DateTime.now();
      final updatedProject = CreateProject(
        title: state.project.title,
        description: state.project.description,
        dateStart: DateTime(now.year, now.month, now.day),
        dateEnd: DateTime(now.year, now.month, now.day),
        budget: state.project.budget,
        location: state.project.location,
        visibility: 'public',
        domains: state.project.domains,
        roleSkills: state.project.roleSkills,
      );

      state = state.copyWith(
        project: updatedProject,
        availableDomains: domains,
        availableRoles: roles,
        availableSkills: skills,
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement: $e');
      state = state.copyWith(
        formError: 'Erreur lors du chargement des données: $e',
        isLoading: false,
      );
    }
  }

  /// Méthode publique pour recharger les données si nécessaire
  Future<void> loadData() async{
    _loadInitialData();
  }

  /// Met à jour le titre du projet
  void updateTitle(String title) {
    final updatedProject = CreateProject(
      title: title,
      description: state.project.description,
      dateStart: state.project.dateStart,
      dateEnd: state.project.dateEnd,
      budget: state.project.budget,
      location: state.project.location,
      visibility: state.project.visibility,
      domains: state.project.domains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
    _clearErrorIfExists();
  }

  /// Met à jour la description du projet
  void updateDescription(String description) {
    final updatedProject = CreateProject(
      title: state.project.title,
      description: description,
      dateStart: state.project.dateStart,
      dateEnd: state.project.dateEnd,
      budget: state.project.budget,
      location: state.project.location,
      visibility: state.project.visibility,
      domains: state.project.domains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
    _clearErrorIfExists();
  }

  /// Met à jour la date de début du projet
  void updateDateStart(DateTime dateStart) {
    final updatedProject = CreateProject(
      title: state.project.title,
      description: state.project.description,
      dateStart: dateStart,
      dateEnd: state.project.dateEnd,
      budget: state.project.budget,
      location: state.project.location,
      visibility: state.project.visibility,
      domains: state.project.domains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
    _clearErrorIfExists();
  }

  /// Met à jour la date de fin du projet
  void updateDateEnd(DateTime dateEnd) {
    final updatedProject = CreateProject(
      title: state.project.title,
      description: state.project.description,
      dateStart: state.project.dateStart,
      dateEnd: dateEnd,
      budget: state.project.budget,
      location: state.project.location,
      visibility: state.project.visibility,
      domains: state.project.domains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
    _clearErrorIfExists();
  }

  /// Met à jour le budget du projet
  void updateBudget(double budget) {
    final updatedProject = CreateProject(
      title: state.project.title,
      description: state.project.description,
      dateStart: state.project.dateStart,
      dateEnd: state.project.dateEnd,
      budget: budget,
      location: state.project.location,
      visibility: state.project.visibility,
      domains: state.project.domains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
    _clearErrorIfExists();
  }

  /// Met à jour le lieu du projet
  void updateLocation(String location) {
    final updatedProject = CreateProject(
      title: state.project.title,
      description: state.project.description,
      dateStart: state.project.dateStart,
      dateEnd: state.project.dateEnd,
      budget: state.project.budget,
      location: location,
      visibility: state.project.visibility,
      domains: state.project.domains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
  }

  /// Met à jour la visibilité du projet
  void updateVisibility(String visibility) {
    final updatedProject = CreateProject(
      title: state.project.title,
      description: state.project.description,
      dateStart: state.project.dateStart,
      dateEnd: state.project.dateEnd,
      budget: state.project.budget,
      location: state.project.location,
      visibility: visibility,
      domains: state.project.domains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
  }

  /// Bascule la sélection d'un domaine
  void toggleDomain(String domainName) {
    final currentDomains = List<String>.from(state.project.domains);

    if (currentDomains.contains(domainName)) {
      currentDomains.remove(domainName);
    } else {
      currentDomains.add(domainName);
    }

    final updatedProject = CreateProject(
      title: state.project.title,
      description: state.project.description,
      dateStart: state.project.dateStart,
      dateEnd: state.project.dateEnd,
      budget: state.project.budget,
      location: state.project.location,
      visibility: state.project.visibility,
      domains: currentDomains,
      roleSkills: state.project.roleSkills,
    );
    state = state.copyWith(project: updatedProject);
  }

  /// Vérifie si un domaine est sélectionné
  bool isDomainSelected(String domainName) {
    return state.project.domains.contains(domainName);
  }

  /// Ajoute un nouveau rôle-compétence
  void addRoleSkill() {
    final currentChosenRoleSkills = List<RoleSkill>.from(state.chosenRoles);
    final currentRoleSkills = List<RoleSkill>.from(state.project.roleSkills);
    final currentNewSkills = List<String>.from(state.newSkills);

    currentChosenRoleSkills.add(RoleSkill(
      role: '',
      skills: [],
      description: '',
    ));
    // currentNewSkills.add('');

    final updatedProject = CreateProject(
      title: state.project.title,
      description: state.project.description,
      dateStart: state.project.dateStart,
      dateEnd: state.project.dateEnd,
      budget: state.project.budget,
      location: state.project.location,
      visibility: state.project.visibility,
      domains: state.project.domains,
      roleSkills: currentChosenRoleSkills,
    );

    state = state.copyWith(
      project: updatedProject,
      newSkills: currentNewSkills,
      chosenRoles: currentChosenRoleSkills

    );
  }

  /// Supprime un rôle-compétence
  void removeRoleSkill(int index) {
    final currentRoleSkills = List<RoleSkill>.from(state.chosenRoles);

    if (index >= 0 && index < currentRoleSkills.length) {
      currentRoleSkills.removeAt(index);

      final updatedProject = CreateProject(
        title: state.project.title,
        description: state.project.description,
        dateStart: state.project.dateStart,
        dateEnd: state.project.dateEnd,
        budget: state.project.budget,
        location: state.project.location,
        visibility: state.project.visibility,
        domains: state.project.domains,
        roleSkills: currentRoleSkills,
      );

      state = state.copyWith(
        project: updatedProject,
        chosenRoles: currentRoleSkills,
      );
    }
  }

  /// Gère le changement de rôle
  void onRoleChange(int index, String role) {
    final currentRoleSkills = List<RoleSkill>.from(state.chosenRoles);

    if(currentRoleSkills.length>0){
     currentRoleSkills[index]= currentRoleSkills[index].copyWith(role: role);
      print("refreshed role \$ ${currentRoleSkills[index].role}");
      state=state.copyWith(chosenRoles: currentRoleSkills);
    }


  }

  /// Met à jour la nouvelle compétence pour un index donné
  void updateNewSkill(int index, String skill) {
    final currentRoleSkills = List<RoleSkill>.from(state.chosenRoles);

    if(currentRoleSkills.length>0){
      var currentskills=currentRoleSkills[index].skills;
      currentskills.add(skill);

      currentskills = currentskills.toSet().toList(); //éliminé les doublons
      currentRoleSkills[index]= currentRoleSkills[index].copyWith(skills: currentskills);
      state=state.copyWith(chosenRoles: currentRoleSkills);
    }
    /*final currentNewSkills = List<String>.from(state.newSkills);

    if (index >= 0 && index < currentNewSkills.length) {
      currentNewSkills[index] = skill;
      state = state.copyWith(newSkills: currentNewSkills);
    }*/
  }

  /// Ajoute une compétence à un rôle spécifique
  void addSkillToRole(int index) {
    if (index < 0 || index >= state.newSkills.length) return;

    final newSkill = state.newSkills[index];
    if (newSkill.trim().isEmpty) return;

    final currentRoleSkills = List<RoleSkill>.from(state.chosenRoles);
    final currentNewSkills = List<String>.from(state.newSkills);

    if (index < currentRoleSkills.length) {
      final currentSkills = List<String>.from(currentRoleSkills[index].skills);

      if (!currentSkills.contains(newSkill)) {
        currentSkills.add(newSkill);
        currentRoleSkills[index] = RoleSkill(
          role: currentRoleSkills[index].role,
          skills: currentSkills,
          description: currentRoleSkills[index].description,
        );

        currentNewSkills[index] = '';

        final updatedProject = CreateProject(
          title: state.project.title,
          description: state.project.description,
          dateStart: state.project.dateStart,
          dateEnd: state.project.dateEnd,
          budget: state.project.budget,
          location: state.project.location,
          visibility: state.project.visibility,
          domains: state.project.domains,
          roleSkills: currentRoleSkills,
        );

        state = state.copyWith(
          project: updatedProject,
          newSkills: currentNewSkills,
        );
      }
    }
  }

  /// Supprime une compétence d'un rôle spécifique
  void removeSkillFromRole(int roleIndex, String skill) {
    final currentRoleSkills = List<RoleSkill>.from(state.chosenRoles);

    if (roleIndex >= 0 && roleIndex < currentRoleSkills.length) {
      final currentSkills = List<String>.from(currentRoleSkills[roleIndex].skills);
      currentSkills.remove(skill);

      currentRoleSkills[roleIndex] = RoleSkill(
        role: currentRoleSkills[roleIndex].role,
        skills: currentSkills,
        description: currentRoleSkills[roleIndex].description,
      );

      final updatedProject = CreateProject(
        title: state.project.title,
        description: state.project.description,
        dateStart: state.project.dateStart,
        dateEnd: state.project.dateEnd,
        budget: state.project.budget,
        location: state.project.location,
        visibility: state.project.visibility,
        domains: state.project.domains,
        roleSkills: currentRoleSkills,
      );

      state = state.copyWith(project: updatedProject,chosenRoles: currentRoleSkills);
    }
  }

  /// Met à jour la description d'un rôle
  void updateRoleDescription(int index, String description) {
    final currentRoleSkills = List<RoleSkill>.from(state.chosenRoles);

    if(currentRoleSkills.length>0){
      currentRoleSkills[index]= currentRoleSkills[index].copyWith(description: description);
      state=state.copyWith(chosenRoles: currentRoleSkills);
    }


    if (index >= 0 && index < currentRoleSkills.length) {
      currentRoleSkills[index] = RoleSkill(
        role: currentRoleSkills[index].role,
        skills: currentRoleSkills[index].skills,
        description: description,
      );

      final updatedProject = CreateProject(
        title: state.project.title,
        description: state.project.description,
        dateStart: state.project.dateStart,
        dateEnd: state.project.dateEnd,
        budget: state.project.budget,
        location: state.project.location,
        visibility: state.project.visibility,
        domains: state.project.domains,
        roleSkills: currentRoleSkills,
      );

      state = state.copyWith(project: updatedProject);
    }
  }

  /// Soumet le formulaire de création de projet
  void onSubmit() async {
    state = state.copyWith(formSubmitted: true);


    // Validation du formulaire
    if (!state.isFormValid) {
      state = state.copyWith(
        formError: 'Veuillez corriger les erreurs dans le formulaire.',
      );
      _clearErrorAfterDelay();
      return;
    }

    try {
      state = state.copyWith(isSubmitting: true, formError: null);
      final token ="";


      final response = await _projectService.createProject(state.project,token);
      print('Payload: ${state.project.toJson()}');




      if (response == true) {
        state = state.copyWith(

          successMessage: 'Projet créé avec succès!',
          isSubmitting: false,

        );
        if (state.isFormValid) {
          state = state.copyWith(
            successMessage: 'Projet crée avec succès.',
          );
          _clearSuccessAfterDelay();
          return;
        }






        //@TODO : Redirection vers une autre page

        print("Projet créé avec succès!");



      } else {
        print(response);
        state = state.copyWith(
          formError: 'Une erreur est survenue lors de la création du projet.',
          isSubmitting: false,
        );
      }
    } catch (e) {

      state = state.copyWith(
        formError: 'Une erreur est survenue lors de la création du projet.',
        isSubmitting: false,
      );
    }
  }

  /// Réinitialise le formulaire
  void resetForm() {
    state = CreateProjectState(
      project: CreateProject.empty(),

      newSkills: [],
      chosenRoles: [],
      isLoading: false,
      isSubmitting: false,
      formSubmitted: false,
      formError: null,
      successMessage: null,
    );
  }


  /// Efface les erreurs
  void clearError() {
    state = state.copyWith(formError: null);
  }

  /// Efface le message de succès
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  // Méthodes privées

  void _clearErrorIfExists() {
    if (state.formError != null) {
      state = state.copyWith(formError: null);
    }
  }

  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        state = state.copyWith(formError: null);
      }
    });
  }

  void _clearSuccessAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        state = state.copyWith(successMessage: null);
      }
    });
  }
}

/// Provider pour le contrôleur du formulaire de projet
final createProjectCtrlProvider = StateNotifierProvider<CreateProjectCtrl, CreateProjectState>(
      (ref) => CreateProjectCtrl(),
);
