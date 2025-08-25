import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String? photoPath;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    photoPath = sp.getString('profile_photo');
    notifyListeners();
  }

  Future<void> pick() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x != null) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('profile_photo', x.path);
      photoPath = x.path;
      notifyListeners();
    }
  }

  File? get file => (photoPath != null) ? File(photoPath!) : null;
}
