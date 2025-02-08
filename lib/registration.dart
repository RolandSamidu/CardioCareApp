import 'package:firebase_auth/firebase_auth.dart';

// Custom error codes
const int registrationSuccess = 1;
const int weakPassword = 2;
const int emailAlreadyInUse = 3;
const int unknownError = 4;

Future<int> registerWithEmailAndPassword(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return registrationSuccess;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      // Weak password error.
      return weakPassword;
    } else if (e.code == 'email-already-in-use') {
      // Email already in use error.
      return emailAlreadyInUse;
    } else {
      // Handle other errors here.
      print('Registration failed: $e');
      return unknownError;
    }
  } catch (e) {
    // Handle any other exceptions here.
    print('Registration failed: $e');
    return unknownError;
  }
}
