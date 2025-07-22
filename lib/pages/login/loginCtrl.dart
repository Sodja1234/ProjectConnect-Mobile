// lib/business/view_models/login/login_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importez Riverpod
import 'package:odc_mobile_template/business/models/user/authentication.dart';
import 'package:odc_mobile_template/business/models/user/user.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';
import '../intro/appCtrl.dart';
import 'login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  // L'instance du service réseau, récupérée via getIt
  final UserNetworkService _userNetworkService = getIt<UserNetworkService>();
  final Ref _ref; // <-- Add a Ref dependency

  LoginController(this._ref)
      : super(LoginState(
    isPasswordVisible: false,
    isLoading: false,
    rememberMe: false,
    emailController: TextEditingController(),
    passwordController: TextEditingController(),
    formKey: GlobalKey<FormState>(),
    error: null,
  ));

  bool get isPasswordVisible => state.isPasswordVisible;
  bool get isLoading => state.isLoading;
  bool get rememberMe => state.rememberMe;
  TextEditingController get emailController => state.emailController;
  TextEditingController get passwordController => state.passwordController;
  GlobalKey<FormState> get formKey => state.formKey;

  // Méthode pour basculer la visibilité du mot de passe.
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
    // Plus besoin de notifyListeners() avec StateNotifier
  }

  // Méthode pour basculer l'état de la case "Se souvenir de moi".
  void toggleRememberMe(bool? value) {
    state = state.copyWith(rememberMe: value ?? false);
    // Plus besoin de notifyListeners() avec StateNotifier
  }

  Future<void> handleLogin() async {
    // Réinitialiser l'erreur avant une nouvelle tentative
    state = state.copyWith(error: null);

    if (state.formKey.currentState!.validate()) {
      state = state.copyWith(isLoading: true);

      try {
        final User user = await _userNetworkService.seConnecter(
          Authentication(
            email: state.emailController.text,
            password: state.passwordController.text,
          ),
        );

        _ref.read(appCtrlProvider.notifier).setUser(user);

        if (state.rememberMe) {
          _ref.read(appCtrlProvider.notifier).userLocalService.enregistrerUser(user);
        }

        // The navigation will be handled by the LoginPage via ref.listen
      } catch (e) {
        String errorMessage;
        if (e is HttpRequestException) {
          errorMessage = e.body ?? 'Erreur réseau inconnue';
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        state = state.copyWith(error: errorMessage); // Met à jour l'état avec l'erreur
      } finally {
        state = state.copyWith(isLoading: false); // Désactive l'indicateur de chargement.
      }
    }
  }

  @override
  void dispose() {

    state.emailController.dispose();
    state.passwordController.dispose();
    super.dispose();
  }
}

final loginCtrlProvider = StateNotifierProvider<LoginController, LoginState>((ref) => LoginController(ref));

