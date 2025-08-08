import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:odc_mobile_template/business/models/project/project.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectCtrl.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectState.dart';
import '../../../main.dart';
import '../../../utils/navigationUtils.dart';

class ListProjectPage extends ConsumerStatefulWidget {
  const ListProjectPage({super.key});

  @override
  ConsumerState<ListProjectPage> createState() => _ListProjectPageState();
}

class _ListProjectPageState extends ConsumerState<ListProjectPage>
    with TickerProviderStateMixin {
  final navigation = getIt<NavigationUtils>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  // Couleurs
  final Color primaryColor = const Color(0xFF1A1A1A);
  final Color accentColor = const Color(0xFFFF6B35);
  final Color lightGray = const Color(0xFFF8F9FA);
  final Color mediumGray = const Color(0xFFE9ECEF);
  final Color darkGray = const Color(0xFF6C757D);
  final Color cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listProjectCtrlProvider.notifier).loadProjects();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final state = ref.read(listProjectCtrlProvider);
    final controller = ref.read(listProjectCtrlProvider.notifier);

    if (currentScroll > (maxScroll * 0.7)) {
      if (!state.isLoadingMore && state.hasNextPage) {
        controller.loadNextPage();
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'fr').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en cours':
        return Colors.green;
      case 'terminé':
        return Colors.blue;
      case 'annulé':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatPeriod(String? start, String? end) {
    if (start == null || end == null) return 'Période non spécifiée';
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatBudget(String? budget) {
    if (budget == null || budget.isEmpty) return 'Budget : Non spécifié';

    final numericValue = double.tryParse(budget);
    if (numericValue == null) return 'Budget : Non spécifié';

    return 'Budget : ${numericValue.toStringAsFixed(0)}\$';
  }

  int? _calculateRemainingDays(String? endDate) {
    if (endDate == null) return null;
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now).inDays;
      return difference;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listProjectCtrlProvider);
    final controller = ref.read(listProjectCtrlProvider.notifier);

    return Scaffold(
      backgroundColor: lightGray,
      appBar: _buildAppBar(controller),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refresh(),
                color: accentColor,
                backgroundColor: Colors.white,
                child: _buildBody(state, controller),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: state.hasPrevPage
          ? FloatingActionButton(
        mini: true,
        backgroundColor: accentColor,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
        onPressed: () {
          controller.loadPrevPage();
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(ListProjectCtrl controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: cardBackground,
      foregroundColor: primaryColor,
      automaticallyImplyLeading: false,
      title: Text(
        'Parcourir les projets',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => controller.refresh(),
            icon: Icon(Icons.refresh_rounded, color: darkGray),
            tooltip: 'Actualiser',
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ListProjectState state, ListProjectCtrl controller) {
    if (state.isLoading && !state.hasProjects) return _buildLoadingState();
    if (state.error != null && !state.hasProjects) {
      return _buildErrorState(state.error!, controller);
    }
    if (!state.hasProjects) return _buildEmptyState(state, controller);

    return Column(
      children: [
        if (state.meta != null) _buildPaginationInfo(state),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: state.projects.length + (state.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.projects.length) {
                return _buildLoadingMoreIndicator(state);
              }
              return AnimatedContainer(
                duration: Duration(milliseconds: 100 * index),
                child: _buildProjectCard(state.projects[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des projets...',
            style: TextStyle(
              fontSize: 16,
              color: darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ListProjectCtrl controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oups ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ListProjectState state, ListProjectCtrl controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun projet disponible',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre premier projet pour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGray,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationInfo(ListProjectState state) {
    final meta = state.meta!;
    return Visibility(
      visible: !state.isLoadingMore,
      child: Opacity(
        opacity: 0.8,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${meta.total} projets • Page ${meta.currentPage}',
            style: TextStyle(
              fontSize: 12,
              color: darkGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(ListProjectState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: state.isLoadingMore
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        )
            : !state.hasNextPage
            ? Text(
          'Fin des résultats',
          style: TextStyle(color: darkGray, fontSize: 12),
        )
            : const SizedBox(),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            GoRouter.of(context).push('/public/projects/${project.slug}');
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectHeader(project),
                const SizedBox(height: 16),
                _buildProjectDescription(project),
                const SizedBox(height: 16),
                _buildProjectMetadata(project),
                if (project.domains.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildProjectDomains(project),
                ],
                if (project.projectRolesSkills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildProjectRoles(project),
                ],
                const SizedBox(height: 16),
                _buildProjectFooter(project),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectHeader(Project project) {
    final statusColor = _getStatusColor(project.status.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                project.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  height: 1.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    project.status.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Créé le ${_formatDate(project.createdAt)} par ${project.createdBy.name}',
          style: TextStyle(
            fontSize: 13,
            color: darkGray,
          ),
        ),
        if (project.budget != null && project.budget!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Text(
              _formatBudget(project.budget),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: accentColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProjectDescription(Project project) {
    return Text(
      project.description,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: darkGray,
        height: 1.5,
        fontSize: 14,
      ),
    );
  }

  Widget _buildProjectMetadata(Project project) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: darkGray),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatPeriod(project.dateStart, project.dateEnd),
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (project.location != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.location_on_rounded, size: 16, color: darkGray),
                const SizedBox(width: 4),
                Text(
                  project.location!,
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDomains(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Domaines concernés (${project.domains.length})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: project.domains.map((domain) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                domain.name,
                style: TextStyle(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProjectRoles(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôles recherchés (${project.projectRolesSkills.length})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...project.projectRolesSkills.map((roleSkill) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mediumGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleSkill.role.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 13,
                  ),
                ),
                if (roleSkill.skills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: roleSkill.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: mediumGray),
                        ),
                        child: Text(
                          skill.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProjectFooter(Project project) {
    final remainingDays = _calculateRemainingDays(project.dateEnd);

    return Column(
      children: [
        if (remainingDays != null) ...[
          Row(
            children: [
              Icon(
                remainingDays > 0 ? Icons.timer_outlined : Icons.timer_off_outlined,
                size: 16,
                color: remainingDays > 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                remainingDays > 0
                    ? '$remainingDays jours restants'
                    : 'Projet terminé',
                style: TextStyle(
                  fontSize: 13,
                  color: remainingDays > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton(
          onPressed: () => GoRouter.of(context).push('/public/projects/${project.slug}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Voir les détails du projet'),
        ),
      ],
    );
  }
}