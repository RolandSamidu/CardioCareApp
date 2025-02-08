import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heart_app/registration.dart';
import 'dart:convert';
import 'package:heart_app/constants/server.dart';
import 'package:http/http.dart' as http;

class RegistrationDoctorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: RegistrationForm(),
        ),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  late int suc = 10;
  String errorMessage = "";
  late String _name;
  late int _code;
  late String _pre;
  late String _contact;
  late String _pass;

  Future<void> createUser() async {
    final apiUrl =
        Uri.parse('${ServerConfig.serverUrl}/user/add');

    try {
      final requestData = {
        "name": _name,
        "code": _code,
        "qualification": _pre,
        "email": _email,
        "role": "Doctor",
        "contact": _contact.isNotEmpty?_contact:'0725237603',
        "password": _pass
      };

      // Send the POST request with the JSON payload
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Request was successful
        print('User created successfully');
      } else {
        // Request failed
        print('Failed to create user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('$_contact An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 5),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.asset(
                  'assets/profile.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'SIGN UP',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                } else {
                  _name = value;
                }
              },
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Doctor ID / Practitioner Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your practitioner code';
                } else {
                  _code = int.parse(value);
                }
              },
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else {
                  _email = value;
                }
              },
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Contact',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your contact number';
                } else {
                  _contact = value;
                }
              },
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Your top qualifications ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current disease status';
                } else {
                  _pre = value;
                }
              },
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else {
                  _pass = value;
                }

              },
              onSaved: (value) => _password = value!,
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Confirm-Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please re-enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final result = await registerWithEmailAndPassword(_email, _password);
                  setState(() {
                    suc = result;
                    if (suc == 1) {
                      createUser();
                      Navigator.pushNamed(context, '/login');
                    }
                    if (suc != 1) {
                      errorMessage = "Something Went Wrong!";
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Register'),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            SizedBox(height: 16),
            Row(children: <Widget>[
              Expanded(child: Divider(color: Colors.black)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('or'),
              ),
              Expanded(child: Divider(color: Colors.black)),
            ]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: "Already have an account?",
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/login');
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      )
    );
  }
}
