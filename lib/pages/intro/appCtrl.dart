// lib/pages/intro/appCtrl.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/models/user/authResponse.dart';
import '../../business/models/user/user.dart';
import '../../utils/localManager.dart'; // Utilise LocalManager directement
import '../../main.dart'; // Pour getIt
import 'appState.dart';

class AppCtrl extends StateNotifier<AppState> {
  // Injecte LocalManager directement
  final LocalManager localManager = getIt<LocalManager>();
  late final ValueNotifier<bool> _isAuthentificatedNotifier;

  ValueNotifier<bool> get isAuthenticatedNotifier => _isAuthentificatedNotifier;

  AppCtrl() : super(AppState(user: null, userToken: null, error: null)) {
    _isAuthentificatedNotifier = ValueNotifier<bool>
      (
      state.userToken != null && state.userToken!.isNotEmpty
        );
    _loadAuthState();
  }

  @override
  set state(AppState value){
    super.state = value;
    final newAuthStatus = value.userToken != null && value.userToken!.isNotEmpty;
    if (_isAuthentificatedNotifier.value != newAuthStatus) {
      _isAuthentificatedNotifier.value = newAuthStatus;
    }

  }


  Future<void> _loadAuthState() async {
    try {
      final user = await localManager.readUser(); // Utilise readUser de LocalManager
      final token = await localManager.readToken(); // Utilise readToken de LocalManager
      state = state.copyWith(user: user, userToken: token);
      print('AppCtrl: User loaded from local storage: ${user?.email ?? 'null'}');
      print('AppCtrl: Token loaded from local storage: ${token != null && token.isNotEmpty ? 'Loaded' : 'null'}');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      print('AppCtrl: Error loading auth state from local storage: $e');
    }
  }

  // --- LA MÉTHODE LOGIN EST ICI ET ACCEPTE UN AuthResponse ---
  Future<void> login(AuthResponse authResponse) async { // <--- CHANGEMENT ICI
    state = state.copyWith(isLoading: true, error: null);
    try {
      final User user = authResponse.data.toUser(); // Extrait l'utilisateur du data
      final String token = authResponse.data.token; // Extrait le token du data

      await localManager.saveUser(user);
      await localManager.saveToken(token);
      state = state.copyWith(user: user, userToken: token, isLoading: false);
      print('AppCtrl: Login successful for user: ${user.email}, token saved.');
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      print('AppCtrl: Error saving auth state: $e');
      rethrow;
    }
  }

  void logout() {
    state = state.copyWith(user: null, userToken: null);
    localManager.deleteUser(); // Utilise deleteUser de LocalManager
    localManager.deleteToken(); // Utilise deleteToken de LocalManager
    print('AppCtrl: User logged out and cleared from storage.');
  }


}

final appCtrlProvider = StateNotifierProvider<AppCtrl, AppState>((ref) {
  return AppCtrl();
});