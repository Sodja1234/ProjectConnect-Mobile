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
  @override
  Future<bool?> inviteForRole(int roleId, String token, String email) async {

      var url = '$baseUrl/project-roles/${roleId}/invite';
      var response = await httpUtils.postData(
        url,
        body: {'email': email},
        token: token,
      );
      print(response);
      return true;

  }

}

void main()async{

  var service=CandidacyNetworkServiceImpl(baseUrl: 'http://10.20.20.244:8000/api', httpUtils: LocalHttpUtils()) ;
  var candidacy = service.inviteForRole(13, "9|3B5DyjEN7onPUWECJ58Dfwrg6afagaegFRInPStj07e73c57", "ephraim17@gmail.com");
  print(candidacy);

}