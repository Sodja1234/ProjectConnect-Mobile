import 'package:odc_mobile_template/business/models/project/project.dart';

class SingleProjectState {
  final Project? project;
  final bool isLoading;
  final String? error;
  final bool isRefreshing; // Pour gérer le refresh spécifique

  SingleProjectState({
    this.project,
    required this.isLoading,
    this.error,
    this.isRefreshing = false,
  });

  factory SingleProjectState.initial() {
    return SingleProjectState(
      project: null,
      isLoading: false,
      error: null,
      isRefreshing: false,
    );
  }

  SingleProjectState copyWith({
    Project? project,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return SingleProjectState(
      project: project ?? this.project,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  // Helpers pour la UI
  bool get hasError => error != null;
  bool get hasData => project != null;
  bool get shouldShowLoading => isLoading && !hasData && !isRefreshing;
  bool get shouldShowContent => hasData && !isLoading && !hasError;
  bool get shouldShowError => hasError && !isLoading;
  bool get shouldShowProgressIndicator => isRefreshing && hasData;
}