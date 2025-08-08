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
  final _scrollController = ScrollController();

  // Palette de couleurs
  final Color primaryColor = const Color(0xFF1A1A1A);
  final Color accentColor = const Color(0xFFFF6B35);
  final Color lightGray = const Color(0xFFF8F9FA);
  final Color mediumGray = const Color(0xFFE9ECEF);
  final Color darkGray = const Color(0xFF6C757D);
  final Color cardBackground = Colors.white;
  final Color successColor = const Color(0xFF28A745);
  final Color errorColor = const Color(0xFFDC3545);
  final Color borderColor = const Color(0xFFDEE2E6);

  // Contrôleurs
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
    _scrollController.dispose();
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
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: primaryColor,
            ),
            dialogBackgroundColor: Colors.white,
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

  InputDecoration _getInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: darkGray.withOpacity(0.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      fillColor: cardBackground,
      filled: true,
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProjectCtrlProvider);
    final ctrl = ref.read(createProjectCtrlProvider.notifier);

    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: Text(
          'Nouveau projet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => navigation.replace('/app/projects'),
        ),
        actions: [
          if (state.isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
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
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ctrl.loadData(),
              tooltip: 'Recharger les données',
            ),
        ],
      ),
      body: Stack(
        children: [
          if (state.isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des données...',
                    style: TextStyle(color: darkGray),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec icône
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 40,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Remplissez les détails de votre projet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Informations de base
                    _buildSectionHeader('Informations de base'),
                    const SizedBox(height: 16),
                    _titleField(),
                    const SizedBox(height: 16),
                    _descriptionField(),
                    const SizedBox(height: 24),

                    // Section Dates et Budget
                    _buildSectionHeader('Dates et Budget'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _startDateField()),
                        const SizedBox(width: 16),
                        Expanded(child: _endDateField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _budgetField()),
                        const SizedBox(width: 16),
                        Expanded(child: _locationField()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section Visibilité et Domaines
                    _buildSectionHeader('Configuration'),
                    const SizedBox(height: 16),
                    _visibilityField(),
                    const SizedBox(height: 16),
                    _domainField(),
                    const SizedBox(height: 24),

                    // Section Rôles et Compétences
                    _buildSectionHeader('Équipe requise'),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Rôles et compétences',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ctrl.addRoleSkill();
                                  _roleControllers.add(TextEditingController());
                                  _descriptionControllers.add(TextEditingController());
                                  _skillControllers.add(TextEditingController());
                                  setState(() {});
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _scrollController.animateTo(
                                      _scrollController.position.maxScrollExtent,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, size: 18),
                                    SizedBox(width: 4),
                                    Text('Rôle'),
                                  ],
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton de soumission
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting ? null : () {
                          if (_formKey.currentState!.validate()) {
                            ctrl.onSubmit();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: accentColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Créer le Projet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

          // Messages d'état
          if (state.successMessage != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildStatusMessage(
                state.successMessage!,
                successColor,
                Icons.check_circle,
                ctrl.clearSuccess,
              ),
            ),
          if (state.formError != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildStatusMessage(
                state.formError!,
                errorColor,
                Icons.error,
                ctrl.clearError,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatusMessage(String message, Color color, IconData icon, VoidCallback onDismiss) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Titre du projet', isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: _getInputDecoration('Ex: Application mobile de gestion'),
          style: TextStyle(color: primaryColor),
          onChanged: ctrl.updateTitle,
          validator: (value) {
            if (state.formSubmitted && (value == null || value.isEmpty)) {
              return 'Veuillez entrer un titre';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _descriptionField() {
    final state = ref.watch(createProjectCtrlProvider);
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Description', isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          minLines: 3,
          style: TextStyle(color: primaryColor),
          decoration: _getInputDecoration('Décrivez votre projet en détail...'),
          onChanged: ctrl.updateDescription,
          validator: (value) {
            if (state.formSubmitted && (value == null || value.isEmpty)) {
              return 'Veuillez entrer une description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _startDateField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Date de début', isRequired: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, true),
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: _getInputDecoration(
              'Sélectionnez une date',
              suffixIcon: Icon(Icons.calendar_today, color: accentColor, size: 20),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(state.project.dateStart),
              style: TextStyle(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _endDateField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Date de fin', isRequired: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, false),
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: _getInputDecoration(
              'Sélectionnez une date',
              suffixIcon: Icon(Icons.calendar_today, color: accentColor, size: 20),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(state.project.dateEnd),
              style: TextStyle(color: primaryColor),
            ),
          ),
        ),
        if (state.formSubmitted && !state.hasValidDateRange)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'La date de fin doit être postérieure ou égale à la date de début',
              style: TextStyle(color: errorColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _budgetField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Budget (€)', isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: primaryColor),
          decoration: _getInputDecoration('Ex: 5000'),
          onChanged: (value) => ctrl.updateBudget(double.tryParse(value) ?? 0),
          validator: (value) {
            if (state.formSubmitted && (value == null || value.isEmpty)) {
              return 'Veuillez entrer un budget';
            }
            if (double.tryParse(value ?? '0') == 0) {
              return 'Le budget doit être supérieur à 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _locationField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Lieu', isRequired: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          style: TextStyle(color: primaryColor),
          decoration: _getInputDecoration('Ex: Remote, Paris, etc.'),
          onChanged: ctrl.updateLocation,
          validator: (value) {
            if (state.formSubmitted && (value == null || value.isEmpty)) {
              return 'Veuillez entrer un lieu';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _visibilityField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Visibilité', isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Text(
                  'Public',
                  style: TextStyle(color: primaryColor),
                ),
                subtitle: Text(
                  'Visible par tous les utilisateurs',
                  style: TextStyle(color: darkGray),
                ),
                value: 'public',
                groupValue: state.project.visibility,
                onChanged: (value) => value != null ? ctrl.updateVisibility(value) : null,
                activeColor: accentColor,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
              RadioListTile<String>(
                title: Text(
                  'Privé',
                  style: TextStyle(color: primaryColor),
                ),
                subtitle: Text(
                  'Visible uniquement par les membres invités',
                  style: TextStyle(color: darkGray),
                ),
                value: 'private',
                groupValue: state.project.visibility,
                onChanged: (value) => value != null ? ctrl.updateVisibility(value) : null,
                activeColor: accentColor,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _domainField() {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Domaines', isRequired: true),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.availableDomains.isEmpty)
                Text(
                  'Aucun domaine disponible',
                  style: TextStyle(color: darkGray),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.availableDomains.map((domain) {
                    return FilterChip(
                      label: Text(domain.name),
                      selected: ctrl.isDomainSelected(domain.name),
                      onSelected: (_) => ctrl.toggleDomain(domain.name),
                      selectedColor: accentColor.withOpacity(0.2),
                      checkmarkColor: accentColor,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: ctrl.isDomainSelected(domain.name)
                              ? accentColor
                              : borderColor,
                          width: 1.5,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: ctrl.isDomainSelected(domain.name)
                            ? accentColor
                            : primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              if (state.formSubmitted && !state.hasAtLeastOneDomain)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Veuillez sélectionner au moins un domaine',
                    style: TextStyle(color: errorColor, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleItemWidget(int index) {
    final state = ref.watch(createProjectCtrlProvider);
    final roleSkill = state.chosenRoles[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: lightGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _roleField(index),
              if (roleSkill.role.isNotEmpty) ...[
                const SizedBox(height: 16),
                ..._roleDescriptionField(index),
                const SizedBox(height: 16),
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
              _buildFieldLabel('Rôle', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roleControllers[index],
                style: TextStyle(color: primaryColor),
                decoration: _getInputDecoration(
                  'Ex: Développeur Frontend',
                  suffixIcon: state.availableRoles.isNotEmpty
                      ? PopupMenuButton<String>(
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
                  )
                      : null,
                ),
                onChanged: (value) => ctrl.onRoleChange(index, value),
                validator: (value) {
                  if (state.formSubmitted && (value == null || value.isEmpty)) {
                    return 'Veuillez entrer un rôle';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.delete_outline, color: errorColor),
          onPressed: () {
            ctrl.removeRoleSkill(index);
            _roleControllers.removeAt(index);
            _descriptionControllers.removeAt(index);
            _skillControllers.removeAt(index);
          },
          tooltip: 'Supprimer ce rôle',
          style: IconButton.styleFrom(
            backgroundColor: errorColor.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  List<Widget> _roleDescriptionField(int index) {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    return [
      _buildFieldLabel('Description du rôle'),
      const SizedBox(height: 8),
      TextFormField(
        controller: _descriptionControllers[index],
        maxLines: 3,
        minLines: 2,
        style: TextStyle(color: primaryColor),
        decoration: _getInputDecoration('Responsabilités, attentes...'),
        onChanged: (value) => ctrl.updateRoleDescription(index, value),
      ),
    ];
  }

  List<Widget> _roleSkillsField(int index) {
    final ctrl = ref.read(createProjectCtrlProvider.notifier);
    final state = ref.watch(createProjectCtrlProvider);
    final roleSkill = state.chosenRoles[index];

    return [
      _buildFieldLabel('Compétences requises'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _skillControllers[index],
              style: TextStyle(color: primaryColor),
              decoration: _getInputDecoration(
                'Ex: Flutter, Firebase',
                suffixIcon: state.availableSkills.isNotEmpty
                    ? PopupMenuButton<String>(
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
                  ))
                      .toList(),
                )
                    : null,
              ),
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  ctrl.updateNewSkill(index, value);
                  _skillControllers[index].clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_skillControllers[index].text.isNotEmpty) {
                ctrl.updateNewSkill(index, _skillControllers[index].text);
                _skillControllers[index].clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (roleSkill.skills.isEmpty)
        Text(
          'Aucune compétence ajoutée',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: darkGray,
            fontSize: 14,
          ),
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
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
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

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        children: isRequired
            ? [
          const TextSpan(text: ' '),
          TextSpan(
            text: '*',
            style: TextStyle(
              color: errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
            : [],
      ),
    );
  }
}