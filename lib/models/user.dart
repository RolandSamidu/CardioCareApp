import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegUser with ChangeNotifier {
  String userName;
  String role = "Patient";
  String name = "";

  RegUser({required this.userName});

  void updateUserName(String newUserName, String newRole, String newName) {
    userName = newUserName;
    role = newRole;
    name = newName;
    notifyListeners();
  }
}