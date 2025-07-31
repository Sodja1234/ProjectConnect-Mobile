// lib/business/models/user/auth_response.dart
import 'package:odc_mobile_template/business/models/user/auth_response_data.dart'; // Importe le nouveau AuthResponseData

class AuthResponse {
  final AuthResponseData data; // Mappe la clé "data" de ta réponse JSON

  AuthResponse({required this.data});

  // Factory constructor pour créer un AuthResponse à partir d'un Map (JSON)
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      data: AuthResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Méthode pour convertir un AuthResponse en Map
  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}