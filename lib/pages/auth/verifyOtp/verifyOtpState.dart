class VerifyOtpState{
  bool? isSubmited;
  String? errorMessage;
  String? successMessage;

  VerifyOtpState({
    this.isSubmited,
    this.errorMessage,
    this.successMessage
});

  VerifyOtpState copyWith({
    bool? isSubmited,
    String? errorMessage,
    String? successMessage,
})=> VerifyOtpState(
      isSubmited: isSubmited ?? this.isSubmited,
      errorMessage: errorMessage ,
      successMessage: successMessage
  );

  factory VerifyOtpState.initial(){
    return VerifyOtpState(
      isSubmited: false,
      errorMessage: null,
      successMessage: null
    );
  }

}