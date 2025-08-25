import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WeatherApi {
  Future<double?> currentTemp(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon&current=temperature_2m',
    );
    final res = await http
        .get(uri, headers: {HttpHeaders.userAgentHeader: 'todo-app/1.0'})
        .timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      final t = (j['current']?['temperature_2m'] as num?);
      return t?.toDouble();
    }
    return null;
  }
}
