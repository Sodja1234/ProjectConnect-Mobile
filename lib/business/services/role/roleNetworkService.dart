import 'package:odc_mobile_template/business/models/role/role.dart';

abstract class RoleNetworkService {
  Future<List<Role>> getRoles();
}