class RegisterUser{
  String name;
  String email;
  String password;
  String password_confirmation;


  RegisterUser({
    required this.name,
    required this.email,
    required this.password,
    required this.password_confirmation

});

  factory RegisterUser.fromJson(Map<String,dynamic>json)=>RegisterUser(
      name: json['name'],
      email: json["email"],
      password: json["password"],
      password_confirmation: json["password_confirmation"]
  );

  Map<String,dynamic> toJson()=>{
    "name":name,
    "email":email,
    "password":password,
    "password_confirmation":password_confirmation
  };

}