import 'dart:convert';

import 'package:odc_mobile_template/business/models/role/role.dart';

import '../../business/services/role/roleNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class RoleNetworkServiceImpl implements RoleNetworkService{

  String? baseUrl;
  HttpUtils? httpUtils;

  RoleNetworkServiceImpl({required this.baseUrl, required this.httpUtils});
  @override
  Future<List<Role>> getRoles() async {

    var url = '$baseUrl/roles';
    var response = await httpUtils!.getData(url);
    var listData = jsonDecode(response);
    var listRoles = listData['data'];
    listRoles =listRoles.map<Role>((e)=>Role.fromJson(e)).toList();
    return listRoles;
  }

}
void main()async{

  var service = RoleNetworkServiceImpl(baseUrl: 'http://10.252.252.6:8000/api', httpUtils: LocalHttpUtils());
  var roles = await service.getRoles();
  roles.forEach((element) {
    print(element.toJson());
  });



}