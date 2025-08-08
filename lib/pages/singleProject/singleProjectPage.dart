import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/pages/singleProject/singleProjectCtrl.dart';
import 'package:odc_mobile_template/pages/singleProject/singleProjectState.dart';
import '../../business/models/project/project.dart';
import '../../business/models/project/projectRoleSkill.dart';
import '../../business/models/user/user.dart';
import '../../main.dart';
import '../../utils/localManager.dart';
import '../../widget/app_shell.dart';

class SingleProjectPage extends ConsumerStatefulWidget {
  final String slug;

  const SingleProjectPage({required this.slug, Key? key}) : super(key: key);

  @override
  ConsumerState<SingleProjectPage> createState() => _SingleProjectPageState();
}

class _SingleProjectPageState extends ConsumerState<SingleProjectPage> {
  final Color primaryColor = const Color(0xFF1A1A1A);
  final Color accentColor = const Color(0xFFFF6B35);
  final Color lightGray = const Color(0xFFF8F9FA);
  final Color mediumGray = const Color(0xFFE9ECEF);
  final Color darkGray = const Color(0xFF6C757D);
  final Color cardBackground = Colors.white;
  final localManager = getIt<LocalManager>();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
    Future.microtask(() => _loadProject());
  }

  Future<void> _loadUser() async {
    currentUser = await localManager.readUser();
  }

  Future<void> _loadProject() async {
    await ref.read(singleProjectCtrlProvider.notifier).loadProject(widget.slug);
  }

  Future<void> _refresh() async {
    await ref.read(singleProjectCtrlProvider.notifier).refresh();
  }

  bool _isCurrentUserCreator(Project project) {
    return currentUser?.id == project.createdBy.id;
  }

  Color _getStatusColor(String status) {
    final normalizedStatus = status.toLowerCase().trim();
    switch (normalizedStatus) {
      case 'en cours':
        return const Color(0xFF4CAF50); // Green 500
      case 'terminé':
        return const Color(0xFF2196F3); // Blue 500
      case 'annulé':
        return const Color(0xFFF44336); // Red 500
      case 'en attente':
        return const Color(0xFFFF9800); // Orange 500
      default:
        return const Color(0xFF9E9E9E); // Grey 500
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(singleProjectCtrlProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Détails du projet',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (state.isRefreshing)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refresh,
              tooltip: 'Rafraîchir',
            ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(SingleProjectState state, ThemeData theme) {
    if (state.isLoading && state.project == null) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (state.error != null && state.project == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Une erreur est survenue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: theme.textTheme.bodyMedium?.copyWith(color: darkGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _refresh,
              ),
            ],
          ),
        ),
      );
    }

    if (state.project != null) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: accentColor,
        backgroundColor: primaryColor.withOpacity(0.1),
        displacement: 40,
        child: _buildProjectDetails(state.project!, theme),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 48, color: darkGray),
          const SizedBox(height: 16),
          Text(
            'Aucune donnée disponible',
            style: theme.textTheme.bodyLarge?.copyWith(color: darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetails(Project project, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec titre et statut
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              project.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(project.status.name).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(project.status.name).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              project.status.name,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: _getStatusColor(project.status.name),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (project.domains.isNotEmpty) ...[
                        Text(
                          'Domaines',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: darkGray,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: project.domains
                              .map(
                                (domain) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: mediumGray,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                domain.name,
                                style: theme.textTheme.labelMedium
                                    ?.copyWith(color: darkGray),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Métadonnées du projet
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations du projet',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.calendar_month_rounded,
                        text: 'Du ${project.dateStart} au ${project.dateEnd}',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.attach_money_rounded,
                        text: 'Budget: ${project.budget} \$',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.location_on_rounded,
                        text: 'Localisation: ${project.location}',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.person_outline_rounded,
                        text: 'Créé par: ${project.createdBy.name}',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_rounded,
                            size: 20,
                            color: accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Description',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        project.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: darkGray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Titre section rôles
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 20,
                        color: accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rôles disponibles',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Section des rôles avec accordéons
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final role = project.projectRolesSkills[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildRoleAccordion(role, theme, project),
            );
          }, childCount: project.projectRolesSkills.length),
        ),
      ],
    );
  }

  Widget _buildRoleAccordion(ProjectRoleSkill roleSkill, ThemeData theme, Project project) {
    final isCreator = _isCurrentUserCreator(project);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: darkGray,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        collapsedBackgroundColor: cardBackground,
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.work_rounded, color: accentColor, size: 20),
        ),
        title: Text(
          roleSkill.role.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${roleSkill.skills.length} compétences requises',
          style: theme.textTheme.labelSmall?.copyWith(color: darkGray),
        ),
        trailing: isCreator
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: mediumGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${roleSkill.candidacies_count} candidatures',
            style: theme.textTheme.labelSmall?.copyWith(color: darkGray),
          ),
        )
            : null,
        children: [
          const SizedBox(height: 8),
          if (roleSkill.skills.isNotEmpty) ...[
            Text(
              'Compétences requises:',
              style: theme.textTheme.labelLarge?.copyWith(
                color: darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: roleSkill.skills
                  .map(
                    (skill) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: mediumGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    skill.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: darkGray,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Description du rôle:',
            style: theme.textTheme.labelLarge?.copyWith(
              color: darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            roleSkill.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: darkGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isCreator
                ? ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Inviter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => _showInviteDialog(context, roleSkill),
            )
                : ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Postuler à ce rôle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                final confirmed = await _showApplyConfirmationDialog(
                    context, roleSkill.role.name);

                if (confirmed == true) {
                  final token = await localManager.readToken();

                  final success = await ref
                      .read(singleProjectCtrlProvider.notifier)
                      .applyForRole(roleSkill.id, token!);

                  if (success == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Candidature envoyée avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    final errorMsg =
                        ref.read(singleProjectCtrlProvider).error ??
                            'Une erreur inconnue est survenue';
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: darkGray,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _showApplyConfirmationDialog(BuildContext context, String roleName) async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: cardBackground,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Confirmer candidature',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Voulez-vous postuler au rôle\n"$roleName" ?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: darkGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: mediumGray,
                      ),
                      child: Text(
                        'Annuler',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: darkGray,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: accentColor,
                      ),
                      child: Text(
                        'Confirmer',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInviteDialog(BuildContext context, ProjectRoleSkill roleSkill) async {
    final theme = Theme.of(context);
    final emailController = TextEditingController();
    final token = await localManager.readToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token non disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: cardBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inviter à ce rôle',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Rôle: ${roleSkill.role.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(Icons.email_rounded, color: accentColor),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isLoading)
                            Flexible(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(120, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: mediumGray,
                                ),
                                child: Text(
                                  'Annuler',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: darkGray,
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(120, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: accentColor,
                              ),
                              child: Text(
                                'Envoyer',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                final email = emailController.text.trim();
                                if (email.isEmpty) {
                                  setState(() {
                                    errorMessage = 'Veuillez entrer un email valide';
                                  });
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                  errorMessage = null;
                                });

                                try {
                                  final success = await ref
                                      .read(singleProjectCtrlProvider.notifier)
                                      .inviteForRole(roleSkill.id, token, email);

                                  if (success == true) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Invitation envoyée à $email'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      errorMessage = ref
                                          .read(singleProjectCtrlProvider)
                                          .error ??
                                          "Échec de l'envoi de l'invitation";
                                    });
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}