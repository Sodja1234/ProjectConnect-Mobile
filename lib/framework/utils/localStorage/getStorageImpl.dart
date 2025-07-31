// lib/localStorage.dart

import 'package:get_storage/get_storage.dart';
import 'package:odc_mobile_template/utils/localManager.dart'; // Importe ta classe abstraite LocalManager
import 'dart:convert'; // Pour jsonEncode et jsonDecode
import 'package:odc_mobile_template/business/models/user/user.dart'; // Pour User.fromJson/toJson

class GetStorageImpl implements LocalManager { // Ici, tu gardes 'implements'
  GetStorage box = GetStorage();

  @override
  Future<String?> readData(String path) async {
    return await box.read(path);
  }

  @override
  Future<bool> writeData(String path, String data) async {
    await box.write(path, data);
    return true;
  }

  @override
  Future<bool> deleteData(String path) async {
    await box.remove(path);
    return true;
  }

  // --- TU DOIS MAINTENANT IMPLÉMENTER TOUTES CES MÉTHODES ICI MANUELLEMENT ---
  @override
  Future<bool> saveUser(User user) async {
    return await writeData('user_data', jsonEncode(user.toJson()));
  }

  @override
  Future<User?> readUser() async {
    final userData = await readData('user_data');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  @override
  Future<bool> deleteUser() async {
    return await deleteData('user_data');
  }

  @override
  Future<bool> saveToken(String token) async {
    return await writeData('user_token', token);
  }

  @override
  Future<String?> readToken() async {
    return await readData('user_token');
  }

  @override
  Future<bool> deleteToken() async {
    return await deleteData('user_token');
  }
}