
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/pages/profil/profil_state.dart';
import '../../business/services/user/profil/user_profil_network_service.dart';
import '../../main.dart';


final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {

  return ProfileController(getIt<UserProfilNetworkService>());
});

class ProfileController extends StateNotifier<ProfileState> {
  final UserProfilNetworkService _userProfilNetworkService;

  // Le constructeur prend le service réseau en paramètre
  ProfileController(this._userProfilNetworkService) : super(ProfileState()) {
    // Action initiale du contrôleur, si nécessaire (ex: charger dès la création)
    // loadProfile(userToken); // Si le token est disponible ici
  }

  Future<void> loadProfile(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: null); // Met l'état en chargement

    try {
      final profile = await _userProfilNetworkService.getUserProfile(token);
      if (profile != null) {
        state = state.copyWith(userProfile: profile, isLoading: false); // Profil chargé
      } else {
        state = state.copyWith(
          userProfile: null,
          isLoading: false,
          errorMessage: 'Profil utilisateur non trouvé ou données invalides.',
        ); // Profil non trouvé
      }
    } catch (e) {
      state = state.copyWith(
        userProfile: null,
        isLoading: false,
        errorMessage: 'Échec de la récupération du profil: $e',
      ); // Erreur
    }
  }
  
}