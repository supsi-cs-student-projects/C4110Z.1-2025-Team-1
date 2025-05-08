import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../services/appwrite.dart';
import '../services/streak.dart';

class AuthService {
  final Account _account = Account(Appwrite.instance.client);
  final StreakService _streakService = StreakService();

  Future<models.Account> signUp(
      {String? name, required String email, required String password}) async {
    await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    return login(email: email, password: password);
  }

  Future<models.Account> login(
      {required String email, required String password}) async {
    await _account.createEmailSession(
      email: email,
      password: password,
    );
    return _account.get();
  }

  Future<models.Account> getAccount() async {
    return _account.get();
  }

  Future<void> logout() {
    return _account.deleteSession(sessionId: 'current');
  }

  Future<String> getName() {
    return _account.get().then((value) => value.name);
  }

  // Metodo per aggiornare lo username
  Future<void> updateUsername(String newUsername) async {
    try {
      await _account.updateName(
          name: newUsername); // Metodo Appwrite per aggiornare il nome
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }
}
