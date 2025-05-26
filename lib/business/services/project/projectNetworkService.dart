import '../../models/project/createProject.dart';

abstract class ProjectNetworkService {

  Future<bool?> createProject(CreateProject project, String token);
}