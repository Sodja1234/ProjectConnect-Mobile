// lib/business/view_models/login/login_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/authentication.dart';
// import 'package:odc_mobile_template/business/models/user/user.dart'; // N'est plus directement nécessaire ici pour la signature de login()
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/pages/intro/appCtrl.dart'; // Import de appCtrlProvider
import '../../../business/models/user/authResponse.dart';
import 'login_state.dart';
//import 'login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  final UserNetworkService _userNetworkService = getIt<UserNetworkService>();
  final Ref _ref;

  LoginController(this._ref)
      : super(LoginState(
    isPasswordVisible: false,
    isLoading: false,
    rememberMe: false,
    emailController: TextEditingController(),
    passwordController: TextEditingController(),
    formKey: GlobalKey<FormState>(),
    error: null,
    isLoginSuccess: false,
  ));

  // Les getters sont une bonne pratique pour accéder à l'état de manière propre
  bool get isPasswordVisible => state.isPasswordVisible;
  bool get isLoading => state.isLoading;
  bool get rememberMe => state.rememberMe;
  TextEditingController get emailController => state.emailController;
  TextEditingController get passwordController => state.passwordController;
  GlobalKey<FormState> get formKey => state.formKey;

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleRememberMe(bool? value) {
    state = state.copyWith(rememberMe: value ?? false);
  }

  Future<void> handleLogin() async {
    // Réinitialise l'erreur et le succès au début de chaque tentative de connexion
    state = state.copyWith(error: null, isLoginSuccess: false);

    if (state.formKey.currentState == null || !state.formKey.currentState!.validate()) {
      return; // Ne pas continuer si le formulaire n'est pas valide
    }

    state = state.copyWith(isLoading: true);

    try {
      // Appel au service réseau qui retourne directement un AuthResponse
      final AuthResponse authResponse = await _userNetworkService.seConnecter(
        Authentication(
          email: state.emailController.text,
          password: state.passwordController.text,
        ),
      );

      // Passe L'OBJET AUTHRESPONSE ENTIER à la méthode login de AppCtrl
      await _ref.read(appCtrlProvider.notifier).login(authResponse);

      // Si aucune exception n'est levée jusqu'ici, la connexion est considérée comme un succès
      state = state.copyWith(isLoading: false, isLoginSuccess: true);

    } on HttpRequestException catch (e) {
      // Gère les exceptions HTTP spécifiques
      String errorMessage;
      // Tu peux affiner les messages d'erreur en fonction du code de statut HTTP
      if (e.statusCode == 401) {
        errorMessage = "Email ou mot de passe incorrect.";
      } else if (e.statusCode == 403) { // Ex: Forbidden
        errorMessage = "Accès refusé. Vérifiez vos permissions.";
      } else if (e.statusCode == 404) { // Ex: Not Found
        errorMessage = "Endpoint API non trouvé. Vérifiez l'URL de l'API.";
      } else if (e.statusCode >= 500) { // Ex: Erreur interne du serveur
        errorMessage = "Erreur serveur inattendue. Veuillez réessayer plus tard.";
      } else {
        errorMessage = e.body ?? "Erreur réseau: ${e.message}";
      }
      print("Erreur HTTP dans LoginController: ${e.message} (StatusCode: ${e.statusCode})");
      state = state.copyWith(error: errorMessage, isLoading: false);

    } catch (e) {
      // Gère toutes les autres exceptions (parsing, etc.)
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      print("Erreur inattendue dans LoginController: $e");
      state = state.copyWith(error: errorMessage, isLoading: false);
    } finally {
      // S'assure toujours que isLoading est faux à la fin de l'opération
      state = state.copyWith(isLoading: false);
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