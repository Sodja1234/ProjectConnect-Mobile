import 'package:odc_mobile_template/business/models/project/project.dart';
import 'package:odc_mobile_template/business/models/project/projectResponse.dart';

import '../../models/project/createProject.dart';

abstract class ProjectNetworkService {

  Future<bool?> createProject(CreateProject project, String token);
  Future<ProjectResponse?> getProjects({

    int page = 1,
    int perPage = 10,
    String? searchQuery,

  });
  Future<Project?> getProject(String slug);
}