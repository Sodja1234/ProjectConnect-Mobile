import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/project/projectNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectState.dart';

class ListProjectCtrl extends StateNotifier<ListProjectState> {
  final ProjectNetworkService _projectService = getIt<ProjectNetworkService>();

  ListProjectCtrl() : super(ListProjectState.initial());

  /// Charge la première page des projets
  Future<void> loadProjects({bool refresh = false, String? searchQuery}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: refresh ? 1 : state.currentPage,
        searchQuery: searchQuery ?? state.searchQuery,
      );

      final response = await _projectService.getProjects(
        page: 1,
        searchQuery: searchQuery ?? state.searchQuery,
      );

      if (response != null) {
        state = state.copyWith(
          projects: response.projects,
          meta: response.meta,
          links: response.links,
          isLoading: false,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Aucune donnée reçue du serveur",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement initial: ${e.toString()}',
      );
    }
  }

  /// Charge une page spécifique
  Future<void> loadPage(int page) async {
    // Empêcher les chargements inutiles
    if (page == state.currentPage ||
        page < 1 ||
        page > (state.meta?.lastPage ?? page) ||
        state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final response = await _projectService.getProjects(
        page: page,
        searchQuery: state.searchQuery,
      );

      if (response != null) {
        state = state.copyWith(
          projects: page == 1
              ? response.projects
              : [...state.projects, ...response.projects],
          meta: response.meta,
          links: response.links,
          isLoadingMore: false,
          currentPage: page,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          error: 'Aucune donnée pour la page $page',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Erreur page $page: ${e.toString()}',
      );
    }
  }

  /// Charge la page suivante avec seuil intelligent
  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoadingMore) return;

    final nextPage = state.currentPage + 1;
    final lastPage = state.meta?.lastPage ?? nextPage;

    // Charger seulement si dans les 70% premières pages
    if (nextPage <= (lastPage * 0.7).ceil() || nextPage == lastPage) {
      await loadPage(nextPage);
    }
  }

  /// Charge la page précédente
  Future<void> loadPrevPage() async {
    if (!state.hasPrevPage || state.isLoadingMore) return;
    await loadPage(state.currentPage - 1);
  }

  /// Recherche de projets
  Future<void> searchProjects(String query) async {
    if (query.trim().isEmpty) {
      await clearSearch();
    } else {
      await loadProjects(refresh: true, searchQuery: query);
    }
  }

  /// Réinitialise la recherche
  Future<void> clearSearch() async {
    if (state.searchQuery != null || state.projects.isNotEmpty) {
      await loadProjects(refresh: true, searchQuery: null);
    }
  }

  /// Rafraîchit les données
  Future<void> refresh() async {
    await loadProjects(refresh: true);
  }

  /// Efface les messages d'erreur
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

final listProjectCtrlProvider = StateNotifierProvider<ListProjectCtrl, ListProjectState>(
        (ref) => ListProjectCtrl()
);