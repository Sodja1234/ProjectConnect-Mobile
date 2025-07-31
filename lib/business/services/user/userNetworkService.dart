import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';
import '../../models/user/authResponse.dart';
import '../../models/user/authentication.dart';
import '../../models/user/user.dart';

// Interface (contrat) pour les opérations réseau liées à l'utilisateur
abstract class UserNetworkService {
  Future<AuthResponse> seConnecter(Authentication authentication); // Renvoie AuthResponse
  Future<User> recupererInfoUtilisateur();
  Future<void> registerUser(RegisterUser registerUser);
  Future<void> verifyOtp(VerifyOtp verifyOtp);
  Future<void> resendOtp(VerifyOtp resendOtp);
}