// lib/utils/localManager.dart
import 'dart:convert';
import 'package:odc_mobile_template/business/models/user/user.dart'; // Assurez-vous que le chemin est correct

abstract class LocalManager {
  // Méthodes abstraites à implémenter par les classes concrètes (e.g., GetStorageImpl)
  Future<String?> readData(String path);
  Future<bool> writeData(String path, String data);
  Future<bool> deleteData(String path);

  // Implémentations par défaut qui utilisent les méthodes abstraites ci-dessus
  // C'est pourquoi tu n'as pas besoin de les implémenter dans GetStorageImpl
  Future<bool> saveUser(User user) async {
    print('LocalManager: Saving user via writeData');
    return await writeData('user_data', jsonEncode(user.toJson()));
  }

  Future<User?> readUser() async {
    print('LocalManager: Reading user via readData');
    final userData = await readData('user_data');
    if (userData != null) {
      print('LocalManager: User data found, decoding...');
      return User.fromJson(jsonDecode(userData));
    }
    print('LocalManager: No user data found.');
    return null;
  }

  Future<bool> deleteUser() async {
    print('LocalManager: Deleting user via deleteData');
    return await deleteData('user_data');
  }

  Future<bool> saveToken(String token) async {
    print('LocalManager: Saving token via writeData');
    return await writeData('user_token', token);
  }

  Future<String?> readToken() async {
    print('LocalManager: Reading token via readData');
    return await readData('user_token');
  }

  Future<bool> deleteToken() async {
    print('LocalManager: Deleting token via deleteData');
    return await deleteData('user_token');
  }
}