import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odc_mobile_template/business/models/project/roleSkill.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectCtrl.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectState.dart';
import 'package:odc_mobile_template/pages/widget/customWidget.dart';

import '../../../main.dart';
import '../../../utils/navigationUtils.dart';

/// Page de création de projet
class ProjectFormPage extends ConsumerStatefulWidget {
  const ProjectFormPage({super.key});

  @override
  ConsumerState<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends ConsumerState<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final navigation = getIt<NavigationUtils>();

  // Couleurs personnalisées
  final Color primaryOrange = const Color(0xFFEA580C); // Orange principal
  final Color lightOrange = const Color(0xFFFDBA74); // Orange clair
  final Color veryLightOrange = const Color(0xFFFFEDD5); // Orange très clair

  // Contrôleurs pour les champs de texte
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final List<TextEditingController> _roleControllers = [];
  final List<TextEditingController> _descriptionControllers = [];
  final List<TextEditingController> _skillControllers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var ctrl = ref.read(createProjectCtrlProvider.notifier);
      ctrl.loadData();
    });

    // Ajouter les listeners après la construction initiale
    Future.microtask(() {
      _titleController.addListener(_clearErrorOnChange);
      _descriptionController.addListener(_clearErrorOnChange);
      _budgetController.addListener(_clearErrorOnChange);
      _locationController.addListener(_clearErrorOnChange);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();

    /*for (final controller in _roleControllers) {
      controller.dispose();
    }*/
    for (final controller in _descriptionControllers) {
      controller.dispose();
    }
    for (final controller in _skillControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _clearErrorOnChange() {
    // Utiliser Future.microtask pour retarder la modification de l'état
    Future.microtask(() {
      if (mounted) {
        final ctrl = ref.read(createProjectCtrlProvider.notifier);
        ctrl.clearError();
      }
    });
  }

  /// Affiche un sélecteur de date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.read(createProjectCtrlProvider);

    final DateTime initialDate =
        isStartDate ? state.project.dateStart : state.project.dateEnd;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (isStartDate) {
        ctrl.updateDateStart(pickedDate);
      } else {
        ctrl.updateDateEnd(pickedDate);
      }
    }
  }

  /// Synchronise les contrôleurs avec l'état
  void _syncControllers(CreateProjectState state) {
    // Désactiver temporairement les listeners
    _titleController.removeListener(_clearErrorOnChange);
    _descriptionController.removeListener(_clearErrorOnChange);
    _budgetController.removeListener(_clearErrorOnChange);
    _locationController.removeListener(_clearErrorOnChange);

    // Synchroniser les contrôleurs de base
   /* if (_titleController.text != state.project.title) {
      _titleController.text = state.project.title;
    }
    if (_descriptionController.text != state.project.description) {
      _descriptionController.text = state.project.description;
    }
    if (_budgetController.text != state.project.budget.toString()) {
      _budgetController.text = state.project.budget.toString();
    }
    if (_locationController.text != state.project.location) {
      _locationController.text = state.project.location;
    }

    // Synchroniser les contrôleurs des rôles
     while (_roleControllers.length < state.project.roleSkills.length) {
      _roleControllers.add(TextEditingController());
      _descriptionControllers.add(TextEditingController());
      _skillControllers.add(TextEditingController());
    }
    while (_roleControllers.length > state.project.roleSkills.length) {
      _roleControllers.removeLast().dispose();
      _descriptionControllers.removeLast().dispose();
      _skillControllers.removeLast().dispose();
    }

    for (int i = 0; i < state.project.roleSkills.length; i++) {
      if (_roleControllers[i].text != state.project.roleSkills[i].role) {
        _roleControllers[i].text = state.project.roleSkills[i].role;
      }
      if (_descriptionControllers[i].text != state.project.roleSkills[i].description) {
        _descriptionControllers[i].text = state.project.roleSkills[i].description;
      }
    }*/

    // Synchroniser les contrôleurs des compétences
    for (int i = 0; i < state.newSkills.length; i++) {
      if (i < _skillControllers.length &&
          _skillControllers[i].text != state.newSkills[i]) {
        _skillControllers[i].text = state.newSkills[i];
      }
    }

    // Réactiver les listeners après la synchronisation
    Future.microtask(() {
      _titleController.addListener(_clearErrorOnChange);
      _descriptionController.addListener(_clearErrorOnChange);
      _budgetController.addListener(_clearErrorOnChange);
      _locationController.addListener(_clearErrorOnChange);
    });
  }

  // Style personnalisé pour les champs de formulaire
  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightOrange),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightOrange),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProjectCtrlProvider);
    final ctrl = ref.read(createProjectCtrlProvider.notifier);

    print("chosen ${state.chosenRoles.length} rows");

    // Synchroniser les contrôleurs
    //_syncControllers(state);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouveau projet'),
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => navigation.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          // Bouton de rechargement pour déboguer
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => ctrl.loadData(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Recharger les données',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Contenu principal
          state.isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                    ),
                    const SizedBox(height: 16),
                    const Text('Chargement des données...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informations de debug
                        const SizedBox(height: 16),

                        // Titre
                         _titleField(),

                        // Description
                         _descriptionField(),

                        // Dates
                        Row(
                          children: [
                            Expanded(child: _startDateField()),
                            const SizedBox(width: 16),
                            Expanded(child: _endDateField()),
                          ],
                        ),

                        // Budget et Lieu
                        Row(
                          children: [
                            Expanded(child: _budgetField()),
                            const SizedBox(width: 16),
                            Expanded(child: _locationField()),
                          ],
                        ),

                        // Visibilité
                         _visibilityField(),

                        // Domaines
                         _domainField(),

                        // Rôles et Compétences
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rôles et Compétences',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                ctrl.addRoleSkill();
                                _roleControllers.add(TextEditingController());
                                _descriptionControllers.add(
                                  TextEditingController(),
                                );
                                _skillControllers.add(TextEditingController());
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 18,
                              ),
                              label: const Text('Ajouter un rôle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor:Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (state.chosenRoles.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Aucun rôle ajouté. Cliquez sur le bouton ci-dessus pour ajouter un rôle.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        // Liste des rôles et compétences
                        ...List.generate(state.chosenRoles.length, (index) {
                          // final roleSkill = state.project.roleSkills[index];
                          return _roleItemWidget(index);
                        }),

                        // Bouton de soumission
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                state.isSubmitting ? null : ctrl.onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: lightOrange,
                            ),
                            child:
                                state.isSubmitting
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Créer le Projet',
                                      style: TextStyle(fontSize: 18),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

          // Messages flottants (Toast)
          if (state.successMessage != null)
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: veryLightOrange,
                    border: Border.all(color: lightOrange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: primaryOrange),
                      const SizedBox(width: 8),
                      Text(
                        state.successMessage!,
                        style: TextStyle(color: primaryOrange),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: ctrl.clearSuccess,
                        child: Icon(
                          Icons.close,
                          color: primaryOrange,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (state.formError != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red.shade500),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        state.formError!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: ctrl.clearError,
                        child: Icon(
                          Icons.close,
                          color: Colors.red.shade700,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _titleField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);

    return FormFields(
      label: 'Titre',
      isRequired: true,
      labelColor: Colors.black,
      child: TextFormField(
        controller: _titleController,
        decoration: _getInputDecoration('Entrez le titre du projet'),
        onChanged: ctrl.updateTitle,
        validator: (value) {
          if (state.formSubmitted && (value == null || value.isEmpty)) {
            return 'Le titre est requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _descriptionField() {
    final state = ref.watch(createProjectCtrlProvider);
    final ctrl = ref.read(createProjectCtrlProvider.notifier);

    return FormFields(
      label: 'Description',
      isRequired: true,
      labelColor: Colors.black,
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: _getInputDecoration('Décrivez votre projet'),
        onChanged: ctrl.updateDescription,
        validator: (value) {
          if (state.formSubmitted && (value == null || value.isEmpty)) {
            return 'La description est requise';
          }
          return null;
        },
      ),
    );
  }

  Widget _startDateField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);

    return FormFields(
      label: 'Date de début',
      isRequired: true,
      labelColor: Colors.black,
      child: InkWell(
        onTap: () => _selectDate(context, true),
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: lightOrange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: lightOrange),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: primaryOrange),
            errorText:
                state.formSubmitted && !state.hasValidDateRange
                    ? 'Date invalide'
                    : null,
            fillColor: Colors.white,
            filled: true,
          ),
          child: Text(DateFormat('dd/MM/yyyy').format(state.project.dateStart)),
        ),
      ),
    );
  }

  Widget _endDateField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return FormFields(
      label: 'Date de fin',
      isRequired: true,
      labelColor:Colors.black,
      child: InkWell(
        onTap: () => _selectDate(context, false),
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: lightOrange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: lightOrange),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: primaryOrange),
            errorText:
                state.formSubmitted && !state.hasValidDateRange
                    ? 'La date de fin doit être postérieure ou égale à la date de début'
                    : null,
            fillColor: Colors.white,
            filled: true,
          ),
          child: Text(DateFormat('dd/MM/yyyy').format(state.project.dateEnd)),
        ),
      ),
    );
  }

  Widget _budgetField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);

    return FormFields(
      label: "Budget",
      isRequired: true,
      labelColor: Colors.black,
      child: TextFormField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        decoration: _getInputDecoration('Budget').copyWith(prefixText: '€ '),
        onChanged: (value) {
          final budget = double.tryParse(value) ?? 0;
          ctrl.updateBudget(budget);
        },
        validator: (value) {
          if (state.formSubmitted && (value == null || value.isEmpty)) {
            return 'Le budget est requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _locationField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);

    return FormFields(
      label: 'Lieu',
      isRequired: true,
      labelColor: Colors.black,
      child: TextFormField(
        controller: _locationController,
        decoration: _getInputDecoration('Ex: Remote, Paris, etc.'),
        onChanged: ctrl.updateLocation,
        validator: (value) {
          if (state.formSubmitted && (value == null || value.isEmpty)) {
            return 'Le lieu est requis';
          }
          return null;
        },
      ),
    );
  }

  Widget _visibilityField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);

    return FormFields(
      label: 'Visibilité',
      isRequired: true,
      labelColor:Colors.black,
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Public'),
              value: 'public',
              groupValue: state.project.visibility,
              onChanged: (value) {
                if (value != null) {
                  ctrl.updateVisibility(value);
                }
              },
              activeColor: primaryOrange,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Privé'),
              value: 'private',
              groupValue: state.project.visibility,
              onChanged: (value) {
                if (value != null) {
                  ctrl.updateVisibility(value);
                }
              },
              activeColor: primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _domainField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return FormFields(
      label: 'Domaines',
      labelColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.availableDomains.isEmpty)
            const Text(
              'Aucun domaine disponible',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  state.availableDomains.map((domain) {
                    final isSelected = ctrl.isDomainSelected(domain.name);
                    return FilterChip(
                      label: Text(domain.name),
                      selected: isSelected,
                      onSelected: (_) => ctrl.toggleDomain(domain.name),
                      selectedColor: veryLightOrange,
                      checkmarkColor: primaryOrange,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: lightOrange, width: 1),
                      ),
                    );
                  }).toList(),
            ),
          if (state.formSubmitted && !state.hasAtLeastOneDomain)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Veuillez sélectionner au moins un domaine.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roleItemWidget(int index) {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    var roleSkill = state.chosenRoles[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightOrange),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rôle et bouton de suppression
              _roleField(index),

              // Description du rôle
              if (roleSkill.role.isNotEmpty) ...[
                ..._roleDescriptionField(index),
                ..._roleSkillsField(index),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleField(int index) {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    var roleSkill = state.chosenRoles[index];

    var _rolePopupMenu = PopupMenuButton<String>(
      icon: Icon(Icons.arrow_drop_down, color: primaryOrange),
      onSelected: (String value) {
        _roleControllers[index].text = value;
        ctrl.onRoleChange(index, value);
      },
      itemBuilder: (BuildContext context) {
        return state.availableRoles.map((role) {
          return PopupMenuItem<String>(
            value: role.name,
            child: Text(role.name),
          );
        }).toList();
      },
    );

    var errorTextValue =
        state.formSubmitted && roleSkill.role.isEmpty
            ? 'Le rôle est requis'
            : null;

    var suffixIconValue =
        state.availableRoles.isNotEmpty ? _rolePopupMenu : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rôle',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roleControllers[index],
                decoration: _getInputDecoration(
                  'Entrez un rôle ou sélectionnez-en un',
                ).copyWith(
                  errorText: errorTextValue,
                  suffixIcon: suffixIconValue,
                ),
                onChanged: (value) => ctrl.onRoleChange(index, value),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => ctrl.removeRoleSkill(index),
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Supprimer ce rôle',
        ),
      ],
    );
  }

  List<Widget> _roleDescriptionField(int index) {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    var roleSkill = state.chosenRoles[index];

    return [
      const SizedBox(height: 16),
      Text(
        'Description du rôle',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _descriptionControllers[index],
        maxLines: 3,
        decoration: _getInputDecoration(
          'Décrivez les responsabilités et attentes pour ce rôle',
        ),
        onChanged: (value) {
          ctrl.updateRoleDescription(index, value);
        },
      ),
    ];
  }

  List<Widget> _roleSkillsField(int index) {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    var roleSkill = state.chosenRoles[index];

    var suffixValue =
        state.availableSkills.isNotEmpty
            ? PopupMenuButton<String>(
              icon: Icon(Icons.arrow_drop_down, color: primaryOrange),
              onSelected: (String value) {
                if (index < _skillControllers.length) {
                  _skillControllers[index].text = value;
                  ctrl.updateNewSkill(index, value);
                  _skillControllers[index].clear();
                }
              },
              itemBuilder: (BuildContext context) {
                return state.availableSkills.where((e)=>!roleSkill.skills.contains(e.name)).map((skill) {
                  return PopupMenuItem<String>(
                    value: skill.name,
                    child: Text(skill.name),
                  );
                }).toList();
              },
            )
            : null;

    // if (roleSkill.role.isNotEmpty)

    return [
      const SizedBox(height: 16),
      Text(
        'Compétences',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const SizedBox(height: 8),

      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _skillControllers[index],
              decoration: _getInputDecoration(
                'Entrez une compétence et appuyez sur Entrée',
              ).copyWith(suffixIcon: suffixValue),
              onChanged: (value) {
                // ctrl.updateNewSkill(index, value);
              },
              onFieldSubmitted: (value) {
                ctrl.updateNewSkill(index, value);
                _skillControllers[index].clear();
                // ctrl.addSkillToRole(index);
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              ctrl.updateNewSkill(index, _skillControllers[index].text);
              _skillControllers[index].clear();

              // ctrl.addSkillToRole(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),

      if (roleSkill.skills.isEmpty)
        const Text(
          'Aucune compétence ajoutée.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
            fontSize: 14,
          ),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              roleSkill.skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  backgroundColor: veryLightOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: lightOrange, width: 1),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    ctrl.removeSkillFromRole(index, skill);
                  },
                  deleteIconColor: primaryOrange,
                );
              }).toList(),
        ),
    ];
  }
}
