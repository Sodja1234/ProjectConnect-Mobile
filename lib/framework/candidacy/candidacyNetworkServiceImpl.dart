import 'package:odc_mobile_template/business/services/candidacy/candidacyNetworkService.dart';

import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class CandidacyNetworkServiceImpl  extends CandidacyNetworkService{
  String baseUrl;
  HttpUtils httpUtils;

  CandidacyNetworkServiceImpl({required this.httpUtils,required this.baseUrl});

  @override
  Future<bool?> applyForRole(int roleId, String token) async{
    var url = '$baseUrl/project-roles/${roleId}/apply';
      var response = await httpUtils.postData(
          url, token: token);
      print(response);
      return true;
  }
  
}

void main()async{

  var service=CandidacyNetworkServiceImpl(baseUrl: 'http://10.252.252.36:8000/api', httpUtils: LocalHttpUtils()) ;
  var candidacy = service.applyForRole(65, "2|l3BN3L5JEcj2LN4EfBsXimd1ugny1DwYpAtagGMPc35f6a2d");
  print(candidacy);

}