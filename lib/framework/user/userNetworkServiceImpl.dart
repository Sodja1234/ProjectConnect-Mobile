
import 'package:odc_mobile_template/business/models/user/registerUser.dart';

import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';

import '../../business/models/user/authentication.dart';

import '../../business/models/user/user.dart';

import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class UserNetworkServiceImpl extends UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<User> recupererInfoUtilisateur() {
    // TODO: implement recupererInfoUtilisateur
    throw UnimplementedError();
  }

  @override
  Future<User> seConnecter(Authentication authentication) {
    // TODO: implement seConnecter
    throw UnimplementedError();
  }

  @override
  Future<void> registerUser(RegisterUser registerUser) async {
   var url = '$baseUrl/register/';
   var body = registerUser.toJson();
   var response = await httpUtils.postData(url,body: body);
   print(response);
   return;
  }

  @override
  Future<void> resendOtp(VerifyOtp resendOtp) {
    // TODO: implement resendOtp
    throw UnimplementedError();
  }

  @override
  Future<void> verifyOtp(VerifyOtp verifyOtp) async {
    var url = '$baseUrl/verify-otp';
    var body = verifyOtp.toJson();
    var response = await httpUtils.postData(url, body : body);
    print(response);
    return ;

  }




  }
void main() async {
  //test register
  var service = UserNetworkServiceImpl(
    baseUrl: "http://10.252.252.61:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  try{
    var data=VerifyOtp(email:'email@gmail.com',otp: '170400');
    var r=await service.verifyOtp(data);
    print(data);

  }catch(e, s){
    print(e);
    print(s);
  }


}