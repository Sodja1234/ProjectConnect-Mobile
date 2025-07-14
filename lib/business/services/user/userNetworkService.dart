import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';

import '../../models/user/authentication.dart';
import '../../models/user/user.dart';

abstract class UserNetworkService {
  Future<User> seConnecter(Authentication authentication);
  Future<User> recupererInfoUtilisateur();
  Future<void> registerUser(RegisterUser registerUser);
  Future<void> verifyOtp(VerifyOtp verifyOtp);
  Future<void> resendOtp(VerifyOtp resendOtp);
}
