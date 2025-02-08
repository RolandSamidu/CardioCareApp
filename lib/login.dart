//

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:heart_app/constants/server.dart';

// Custom error codes
const int loginSuccess = 1;
const int invalidEmailPassword = 2;
const int userNotFound = 3;
const int accountDisabled = 4;
const int unknownError = 5;

Future<int> loginWithEmailAndPassword(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Login successful, return success code.
    return loginSuccess;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-email' || e.code == 'wrong-password') {
      // Invalid email or password.
      return invalidEmailPassword;
    } else if (e.code == 'user-not-found') {
      // User not found.
      return userNotFound;
    } else if (e.code == 'user-disabled') {
      // User account is disabled.
      return accountDisabled;
    } else {
      return unknownError;
    }
  } catch (e) {
    return unknownError;
  }
}

Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  final baseUrl = '${ServerConfig.serverUrl}/user';
  final apiUrl = Uri.parse('$baseUrl/get?email=$email');

  try {
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      print(response.body);
      final Map<String, dynamic> user = json.decode(response.body);
      return user;
    } else {
      print('Failed to load user. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching user: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getRecord(String patientEmail) async {
  final baseUrl = '${ServerConfig.serverUrl}/user/get-record';
  final apiUrl = Uri.parse('$baseUrl?patient_email=$patientEmail');

  try {
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> record = json.decode(response.body);
      return record;
    } else {
      print('Failed to load record. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching record: $e');
    return null;
  }
}

Future<bool> sendOTP(String mobile, String message) async {
  try {
    if (mobile.isNotEmpty && message.isNotEmpty) {
      final response = await http.get(
        Uri.parse(
          'https://app.notify.lk/api/v1/send?user_id=23201&api_key=aElC8iVmQG05Aqk60tWj&sender_id=NotifyDEMO&to=+94${mobile.substring(1)}&message=$message',
        ),
      );

      if (response.statusCode == 200) {
        // API request was successful
        return true;
      } else {
        // API request failed
        print('Failed to send OTP. Status code: ${response.statusCode}');
      }
    } else {
      print('Mobile number or token is empty');
    }
  } catch (e) {
    print('Error sending OTP: $e');
  }

  return false;
}


