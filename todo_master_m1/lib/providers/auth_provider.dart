import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_api.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApi api;
  final _secure = const FlutterSecureStorage();
  int? accountId;
  String? email;

  AuthProvider(this.api);

  Future<bool> tryAutoLogin() async {
    final sp = await SharedPreferences.getInstance();
    final storedId = sp.getInt('account_id');
    final storedEmail = sp.getString('email');
    if (storedId != null && storedEmail != null) {
      accountId = storedId;
      email = storedEmail;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password, {bool register = false}) async {
  final res = register
      ? await api.register(email, password)
      : await api.login(email, password);


  if (register && res['data'] is String) {
    final again = await api.login(email, password);
    final id2 = int.tryParse('${again['data']?['account_id'] ?? ''}');
    if (id2 == null) return false;
    await _persist(id2, email, password);
    return true;
  }

  final id = int.tryParse('${res['data']?['account_id'] ?? ''}');
  if (id == null) return false;
  await _persist(id, email, password);
  return true;
}

Future<void> _persist(int id, String email, String password) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setInt('account_id', id);
  await sp.setString('email', email);
  await _secure.write(key: 'password', value: password);
  accountId = id; this.email = email;
  notifyListeners();
}


  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('account_id');
    await sp.remove('email');
    await _secure.delete(key: 'password');

    accountId = null;
    email = null;
    notifyListeners();
  }
}
