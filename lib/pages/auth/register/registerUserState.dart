

class RegisterUserState{
  bool? isSubmited;
  String? successMessage;
  String? errorMessage;
  String? email;

  RegisterUserState({
    this.isSubmited,
    this.successMessage,
    this.errorMessage,
    this.email,

});

  RegisterUserState copyWith({  bool? isSubmited,
  String? successMessage,
  String? errorMessage,
  String? email,

})=> RegisterUserState(
    isSubmited: isSubmited ?? this.isSubmited,
    successMessage: successMessage ?? this.successMessage,
    errorMessage: errorMessage ?? this.errorMessage,
    email: email ?? this.email
  );


  factory RegisterUserState.initial(){
    return RegisterUserState(
      isSubmited: false,
      errorMessage: null,
      successMessage: null,

    );
  }
}