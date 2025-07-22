// lib/pages/intro/appCtrl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/models/user/user.dart'; // Ensure this import is correct for your User model
import '../../business/services/user/userLocalService.dart';
import '../../main.dart';
import 'appState.dart'; // Ensure this import is correct for your AppState

class AppCtrl extends StateNotifier<AppState> {
  var userLocalService = getIt<UserLocalService>();

  AppCtrl() : super(AppState(user: null, error: null)) {
    // It's good practice to try and load the user right away when the controller is created
    getUser();
  }

  // Method to set the user (called after successful login)
  void setUser(User? newUser) {
    state = state.copyWith(user: newUser);
    print('AppCtrl: User state updated to: ${newUser?.email ?? 'null'}'); // For debugging
  }

  Future<void> getUser() async {
    try {
      var user = await userLocalService.recupererUser();
      state = state.copyWith(user: user);
      print('AppCtrl: User loaded from local service: ${user?.email ?? 'null'}'); // For debugging
    } catch (e) {
      state = state.copyWith(error: e.toString());
      print('AppCtrl: Error loading user from local service: $e'); // For debugging
    }
  }

  // You might also want a logout method
  void logout() {
    state = state.copyWith(user: null);
    userLocalService.supprimerUser(); // Clear user from local storage
    print('AppCtrl: User logged out and cleared from storage.');
  }
}

final appCtrlProvider = StateNotifierProvider<AppCtrl, AppState>((ref) {
  // ref.keepAlive(); // Keep alive is usually not needed for AppCtrl unless specific reason
  // It can sometimes hide issues if the provider is never disposed when it should be.
  return AppCtrl();
});
