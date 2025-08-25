import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool online = true;
  ConnectivityProvider() {
    Connectivity().onConnectivityChanged.listen((result) {
      online = !(result.contains(ConnectivityResult.none));
      notifyListeners();
    });
  }
}
