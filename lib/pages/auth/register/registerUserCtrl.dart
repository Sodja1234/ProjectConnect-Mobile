



import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/register/registerUserState.dart';

import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';

class RegisterUserCtrl extends StateNotifier<RegisterUserState>{
  final UserNetworkService network = getIt.get<UserNetworkService>();
  RegisterUserCtrl(): super(RegisterUserState());

  Future<bool> register(RegisterUser user) async{
    state = state.copyWith(
      isSubmited: true,
      successMessage: null,
      errorMessage: null
    );
    try{
      await network.registerUser(user);
      state =state.copyWith(
        isSubmited: true,
        successMessage: "Inscription réussie !",
        email: user.email
      );
      durationToast();
      return true ;

    }on HttpRequestException catch (e){
      state =state.copyWith(
        isSubmited: false,
        errorMessage: "${e.body.toString()}",
      );
      print('error : ${e.body}');
      durationToast();
      return false;

    }on TimeoutException catch(_){
      state = state.copyWith(
        isSubmited : false,
        errorMessage: "Temps d'attente dépassé. Le serveur ne répond pas.",
      );
      durationToast();
      return false;
    }catch (e){
      state = state.copyWith(
        isSubmited: false,
        errorMessage: "Erreur serveur : $e",
      );
      durationToast();
      return false;


    }
  }

  // Méthode resetMessages
  void resetMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
      isSubmited: false,
    );
  }

  void durationToast(){
    Future.delayed(Duration(seconds: 3),(){
      resetMessages();
    });
  }


}

final RegisterUserCtrlProvider = StateNotifierProvider<RegisterUserCtrl,RegisterUserState>((ref){
  return RegisterUserCtrl();
});