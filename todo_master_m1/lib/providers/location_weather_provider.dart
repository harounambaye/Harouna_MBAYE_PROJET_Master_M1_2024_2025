import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../services/weather_api.dart';

class LocationWeatherProvider extends ChangeNotifier {
  final WeatherApi api;

  double? temp; 
  double? lat;
  double? lon;
  String? place;   

  bool loading = false;
  String? error;     
  String? debugInfo; 

  LocationWeatherProvider(this.api);

  Future<void> load() async {
    loading = true; error = null; debugInfo = null; place = null;
    notifyListeners();

    try {
      // 1) Ici je test les Services actifs 
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error = 'Localisation désactivée (active le GPS).';
        debugInfo = 'isLocationServiceEnabled=false';
        loading = false; notifyListeners(); return;
      }

      // 2) Permissions
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.deniedForever) {
        error = 'Permission localisation refusée définitivement.\nAutorise-la dans les réglages.';
        debugInfo = 'deniedForever';
        loading = false; notifyListeners(); return;
      }
      if (p == LocationPermission.denied) {
        error = 'Permission localisation refusée.';
        debugInfo = 'denied';
        loading = false; notifyListeners(); return;
      }

      // 3) Position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 8));
      lat = pos.latitude; lon = pos.longitude;

      // 4) Reverse geocoding 
      try {
        final placemarks = await geo.placemarkFromCoordinates(lat!, lon!)
            .timeout(const Duration(seconds: 8));
        place = _formatPlace(placemarks);
      } on TimeoutException {
        debugInfo = 'reverse geocoding timeout';
      } catch (e) {
        debugInfo = 'reverse geocoding error: $e';
      }

      // 5) Météo
      temp = await api.currentTemp(lat!, lon!).timeout(const Duration(seconds: 8));
      if (temp == null) error = 'Météo indisponible (réseau ?)';
    } on TimeoutException {
      error = 'Localisation/Météo indisponible (timeout).';
      debugInfo = 'timeout';
    } catch (e) {
      error = 'Localisation/Météo indisponible';
      debugInfo = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  Future<void> setManual(double latitude, double longitude) async {
    lat = latitude; lon = longitude; place = null;
    loading = true; error = null; notifyListeners();
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat!, lon!);
      place = _formatPlace(placemarks);
      temp = await api.currentTemp(lat!, lon!);
    } catch (e) {
      error = 'Météo/lieu indisponible';
      debugInfo = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> openLocationSettings() async => Geolocator.openLocationSettings();
  Future<void> openAppSettings() async => Geolocator.openAppSettings();

  String? _formatPlace(List<geo.Placemark> list) {
    if (list.isEmpty) return null;
    final p = list.first;
   
    final parts = <String>[
      if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),           // Ville 
      if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),     // Quartier
      if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),             // Pays
    ];
    if (parts.isEmpty) {
      final alt = <String>[
        if ((p.administrativeArea ?? '').trim().isNotEmpty) p.administrativeArea!.trim(),
        if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
      ];
      return alt.isEmpty ? null : alt.join(', ');
    }
    return parts.join(', ');
  }
}
