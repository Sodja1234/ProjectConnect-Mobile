import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odc_mobile_template/business/models/project/roleSkill.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectCtrl.dart';
import 'package:odc_mobile_template/pages/createProject/createProjectState.dart';
import '../../../main.dart';
import '../../../utils/navigationUtils.dart';
import '../../widget/customWidget.dart';

class ProjectFormPage extends ConsumerStatefulWidget {
  const ProjectFormPage({super.key});

  @override
  ConsumerState<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends ConsumerState<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final navigation = getIt<NavigationUtils>();

  // Définition des couleurs comme dans ListProjectPage
  final Color primaryColor = const Color(0xFF1A1A1A);      // Noir pour les titres
  final Color accentColor = const Color(0xFFFF6B35);         // Orange principal
  final Color lightGray = const Color(0xFFF8F9FA);         // Gris très clair pour les backgrounds
  final Color mediumGray = const Color(0xFFE9ECEF);        // Gris moyen pour les bordures
  final Color darkGray = const Color(0xFF6C757D);          // Gris foncé pour le texte secondaire
  final Color cardBackground = Colors.white;               // Blanc pour les cards

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
      ref.read(createProjectCtrlProvider.notifier).loadData();
    });
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
    for (final controller in _descriptionControllers) {
      controller.dispose();
    }
    for (final controller in _skillControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearErrorOnChange() {
    Future.microtask(() {
      if (mounted) {
        ref.read(createProjectCtrlProvider.notifier).clearError();
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.read(createProjectCtrlProvider);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? state.project.dateStart : state.project.dateEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      isStartDate
          ? ctrl.updateDateStart(pickedDate)
          : ctrl.updateDateEnd(pickedDate);
    }
  }

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: darkGray),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: mediumGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: mediumGray),
      ),
      fillColor: cardBackground,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProjectCtrlProvider);
    final ctrl = ref.read(createProjectCtrlProvider.notifier);

    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Nouveau projet'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => navigation.replace('/public/home'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
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
          state.isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
                const SizedBox(height: 16),
                const Text('Chargement des données...'),
              ],
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _titleField(),
                  _descriptionField(),
                  Row(
                    children: [
                      Expanded(child: _startDateField()),
                      const SizedBox(width: 16),
                      Expanded(child: _endDateField()),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _budgetField()),
                      const SizedBox(width: 16),
                      Expanded(child: _locationField()),
                    ],
                  ),
                  _visibilityField(),
                  _domainField(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rôles et Compétences',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ctrl.addRoleSkill();
                          _roleControllers.add(TextEditingController());
                          _descriptionControllers.add(TextEditingController());
                          _skillControllers.add(TextEditingController());
                          setState(() {});
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Ajouter un rôle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.chosenRoles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Aucun rôle ajouté. Cliquez sur le bouton ci-dessus pour ajouter un rôle.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: darkGray,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ...List.generate(state.chosenRoles.length, (index) => _roleItemWidget(index)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting ? null : ctrl.onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: accentColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Créer le Projet', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (state.successMessage != null)
            Positioned(
              top: 16,
              right: 16,
              child: SuccessMessage(
                message: state.successMessage!,
                onDismiss: ctrl.clearSuccess,
              ),
            ),
          if (state.formError != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: ErrorMessage(
                message: state.formError!,
                onDismiss: ctrl.clearError,
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
      labelColor: primaryColor,
      child: TextFormField(
        controller: _titleController,
        decoration: _getInputDecoration('Entrez le titre du projet'),
        style: TextStyle(color: primaryColor),
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
      labelColor: primaryColor,
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        style: TextStyle(color: primaryColor),
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
      labelColor: primaryColor,
      child: InkWell(
        onTap: () => _selectDate(context, true),
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mediumGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mediumGray),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: accentColor),
            errorText: state.formSubmitted && !state.hasValidDateRange ? 'Date invalide' : null,
            fillColor: cardBackground,
            filled: true,
          ),
          child: Text(
            DateFormat('dd/MM/yyyy').format(state.project.dateStart),
            style: TextStyle(color: primaryColor),
          ),
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
      labelColor: primaryColor,
      child: InkWell(
        onTap: () => _selectDate(context, false),
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mediumGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mediumGray),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: accentColor),
            errorText: state.formSubmitted && !state.hasValidDateRange
                ? 'La date de fin doit être postérieure ou égale à la date de début'
                : null,
            fillColor: cardBackground,
            filled: true,
          ),
          child: Text(
            DateFormat('dd/MM/yyyy').format(state.project.dateEnd),
            style: TextStyle(color: primaryColor),
          ),
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
      labelColor: primaryColor,
      child: TextFormField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: primaryColor),
        decoration: _getInputDecoration('Budget').copyWith(prefixText: '€ '),
        onChanged: (value) => ctrl.updateBudget(double.tryParse(value) ?? 0),
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
      labelColor: primaryColor,
      child: TextFormField(
        controller: _locationController,
        style: TextStyle(color: primaryColor),
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
      labelColor: primaryColor,
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: Text('Public', style: TextStyle(color: primaryColor)),
              value: 'public',
              groupValue: state.project.visibility,
              onChanged: (value) => value != null ? ctrl.updateVisibility(value) : null,
              activeColor: accentColor,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: Text('Privé', style: TextStyle(color: primaryColor)),
              value: 'private',
              groupValue: state.project.visibility,
              onChanged: (value) => value != null ? ctrl.updateVisibility(value) : null,
              activeColor: accentColor,
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
      labelColor: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.availableDomains.isEmpty)
            Text('Aucun domaine disponible', style: TextStyle(color: darkGray))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.availableDomains.map((domain) {
                return FilterChip(
                  label: Text(domain.name),
                  selected: ctrl.isDomainSelected(domain.name),
                  onSelected: (_) => ctrl.toggleDomain(domain.name),
                  selectedColor: accentColor.withOpacity(0.1),
                  checkmarkColor: accentColor,
                  backgroundColor: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: mediumGray, width: 1),
                  ),
                  labelStyle: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          if (state.formSubmitted && !state.hasAtLeastOneDomain)
            Padding(
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
    final state = ref.watch(createProjectCtrlProvider);
    final roleSkill = state.chosenRoles[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: mediumGray),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _roleField(index),
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
    final roleSkill = state.chosenRoles[index];
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rôle', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roleControllers[index],
                style: TextStyle(color: primaryColor),
                decoration: _getInputDecoration('Entrez un rôle ou sélectionnez-en un').copyWith(
                  errorText: state.formSubmitted && roleSkill.role.isEmpty ? 'Le rôle est requis' : null,
                  suffixIcon: state.availableRoles.isNotEmpty ? PopupMenuButton<String>(
                    icon: Icon(Icons.arrow_drop_down, color: accentColor),
                    onSelected: (value) {
                      _roleControllers[index].text = value;
                      ctrl.onRoleChange(index, value);
                    },
                    itemBuilder: (context) => state.availableRoles.map((role) {
                      return PopupMenuItem<String>(
                        value: role.name,
                        child: Text(role.name),
                      );
                    }).toList(),
                  ) : null,
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
    return [
      const SizedBox(height: 16),
      Text('Description du rôle', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
      const SizedBox(height: 8),
      TextFormField(
        controller: _descriptionControllers[index],
        maxLines: 3,
        style: TextStyle(color: primaryColor),
        decoration: _getInputDecoration('Décrivez les responsabilités et attentes pour ce rôle'),
        onChanged: (value) => ctrl.updateRoleDescription(index, value),
      ),
    ];
  }

  List<Widget> _roleSkillsField(int index) {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    final roleSkill = state.chosenRoles[index];
    return [
      const SizedBox(height: 16),
      Text('Compétences', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _skillControllers[index],
              style: TextStyle(color: primaryColor),
              decoration: _getInputDecoration('Entrez une compétence et appuyez sur Entrée').copyWith(
                suffixIcon: state.availableSkills.isNotEmpty ? PopupMenuButton<String>(
                  icon: Icon(Icons.arrow_drop_down, color: accentColor),
                  onSelected: (value) {
                    _skillControllers[index].text = value;
                    ctrl.updateNewSkill(index, value);
                    _skillControllers[index].clear();
                  },
                  itemBuilder: (context) => state.availableSkills
                      .where((e) => !roleSkill.skills.contains(e.name))
                      .map((skill) => PopupMenuItem<String>(
                    value: skill.name,
                    child: Text(skill.name),
                  )).toList(),
                ) : null,
              ),
              onFieldSubmitted: (value) {
                ctrl.updateNewSkill(index, value);
                _skillControllers[index].clear();
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              ctrl.updateNewSkill(index, _skillControllers[index].text);
              _skillControllers[index].clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
      if (roleSkill.skills.isEmpty)
        Text(
          'Aucune compétence ajoutée.',
          style: TextStyle(fontStyle: FontStyle.italic, color: darkGray, fontSize: 14),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: roleSkill.skills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: accentColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: mediumGray, width: 1),
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => ctrl.removeSkillFromRole(index, skill),
              deleteIconColor: accentColor,
              labelStyle: TextStyle(
                color: primaryColor,
                fontSize: 13,
              ),
            );
          }).toList(),
        ),
    ];
  }
}