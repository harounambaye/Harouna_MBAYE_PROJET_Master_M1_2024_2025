import 'api_service.dart';

class AuthApi {
  final ApiService _api;
  AuthApi(this._api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _api.post('login', {"email": email, "password": password});
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    return await _api.post('register', {"email": email, "password": password});
  }
}
