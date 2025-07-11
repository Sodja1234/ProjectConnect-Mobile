import 'package:odc_mobile_template/business/models/project/project.dart';
import 'package:odc_mobile_template/business/models/project/projectResponse.dart';

class ListProjectState{
  final List<Project> projects;
  final PaginationMeta? meta;
  final PaginationLinks? links;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final String? searchQuery;

  ListProjectState({
    required this.projects,
    this.meta,
    this.links,
    required this.isLoading,
    required this.isLoadingMore,
    this.error,
    required this.currentPage,
    this.searchQuery,
  });

  factory ListProjectState.initial() {
    return ListProjectState(
      projects: [],
      isLoading: false,
      isLoadingMore: false,
      currentPage: 1,
    );
  }
  ListProjectState copyWith({
    List<Project>? projects,
    PaginationMeta? meta,
    PaginationLinks? links,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    String? searchQuery,

}){
    return ListProjectState(
      projects: projects ?? this.projects,
      meta: meta ?? this.meta,
      links: links ?? this.links,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasNextPage => links?.next != null;
  bool get hasPrevPage => links?.prev != null;
  bool get hasProjects => projects.isNotEmpty;

  // Propriétés utiles pour la pagination
  int get totalPages => meta?.lastPage ?? 1;
  int get totalProjects => meta?.total ?? 0;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage == totalPages;


}