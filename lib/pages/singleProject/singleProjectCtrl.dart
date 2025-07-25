import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/pages/singleProject/singleProjectState.dart';
import '../../business/services/project/projectNetworkService.dart';
import '../../main.dart';

class SingleProjectCtrl extends StateNotifier<SingleProjectState> {
  final ProjectNetworkService _projectService;
  String? _currentSlug;

  SingleProjectCtrl(this._projectService)
      : super(SingleProjectState.initial());

  Future<void> loadProject(String slug) async {
    try {
      debugPrint('[SingleProjectCtrl] Loading project with slug: $slug');

      // Réinitialiser l'état seulement si c'est un nouveau projet différent
      if (_currentSlug != slug) {
        state = SingleProjectState.initial();
        debugPrint('[SingleProjectCtrl] State reset for new project');
      }

      _currentSlug = slug;
      state = state.copyWith(isLoading: true, error: null);
      debugPrint('[SingleProjectCtrl] Loading started for slug: $slug');

      final project = await _projectService.getProject(slug);
      debugPrint('[SingleProjectCtrl] Received project data: ${project != null ? "success" : "null"}');

      if (project == null) {
        debugPrint('[SingleProjectCtrl] Project not found for slug: $slug');
        throw Exception('Project not found');
      }

      state = state.copyWith(
        project: project,
        isLoading: false,
        error: null,
      );
      debugPrint('[SingleProjectCtrl] Project loaded successfully: ${project.title}');

    } catch (e, stack) {
      debugPrint('[SingleProjectCtrl] Error loading project: $e');
      debugPrint(stack.toString());

      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
        project: null, // On efface toujours le projet en cas d'erreur
      );
      debugPrint('[SingleProjectCtrl] State cleared due to error');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is FormatException) return 'Invalid data format from server';
    if (error is TypeError) return 'Type error during data processing';
    return 'Failed to load project: ${error.toString()}';
  }

  Future<void> refresh() async {
    if (_currentSlug != null) {

      state = state.copyWith(isRefreshing: true);
      try {
        await loadProject(_currentSlug!);
      } finally {
        state = state.copyWith(isRefreshing: false);
      }
    } else {
      debugPrint('[SingleProjectCtrl] No slug available for refresh');
    }
  }

  void clearState() {
    state = SingleProjectState.initial();
    _currentSlug = null;
  }
}

final singleProjectCtrlProvider = StateNotifierProvider<SingleProjectCtrl, SingleProjectState>(
      (ref) => SingleProjectCtrl(getIt<ProjectNetworkService>()),
);