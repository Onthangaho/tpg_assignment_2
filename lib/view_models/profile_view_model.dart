/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */

import 'package:flutter/material.dart';
import 'package:login_form/auth/auth.dart';

import '../models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final Auth _authService;
  UserModel? _user;
  bool _isEditing = false;
  String? _imagePath;

  ProfileViewModel(this._authService) {
    _loadUserData();
  }

  UserModel? get user => _user;
  bool get isEditing => _isEditing;
  String? get imagePath => _imagePath;


  void _loadUserData() async {
    _user = await _authService.getUserData(_authService.currentUser!.uid);
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

 Future<void> updateProfile(String name, String studentNumber, String contactNumber) async {
  try {
    await _authService.updateUserProfile(_authService.currentUser!.uid, name, studentNumber, contactNumber);

    // 🔹 Instant UI Update Instead of Fetching Again
   _user = UserModel(
  id: _authService.currentUser!.uid, // 🔹 Ensure user ID is provided
  email: _authService.currentUser!.email ?? "N/A", // 🔹 Default to "N/A" if email is null
  role: _user?.role ?? "student", // 🔹 Default role if not available
  name: name,
  studentNumber: studentNumber,
  contactNumber: contactNumber,
   createdAt: _user?.createdAt ?? DateTime.now(), 
);


    notifyListeners(); // 🔹 UI refreshes instantly without waiting for Firestore
  } catch (e) {
    print("❌ Profile update failed: $e");
  }
}
   void updateImage(String path) {
    _imagePath = path;
    notifyListeners(); // 🔹 Updates UI when changing profile picture
  }

}