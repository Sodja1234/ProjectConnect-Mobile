// create a state class for the home page

import '../../business/models/user/user.dart';

class AppState {
  User? user;
  bool? isLoading = false;
  String? error;
  String? userToken;

  AppState({this.user, this.isLoading, this.error, this.userToken});

  AppState copyWith({User? user, bool? isLoading, String? error, String ? userToken}) {
    return AppState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error ?? this.error, userToken : userToken ?? this.userToken);
  }
  
  
}


