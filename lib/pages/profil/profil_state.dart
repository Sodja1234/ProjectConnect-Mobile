
import '../../business/models/user/profil/profil.dart';

class ProfileState {
  final UserProfile? userProfile;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.userProfile,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserProfile? userProfile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}