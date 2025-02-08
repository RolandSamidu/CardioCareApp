import 'package:heart_app/models/user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heart_app/login.dart';
import 'package:provider/provider.dart';

class SwitchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 50),

          child: SwitchUser(),
        ),
      ),
    );
  }
}

class SwitchUser extends StatefulWidget {
  @override
  _SwitchUserState createState() => _SwitchUserState();
}

class _SwitchUserState extends State<SwitchUser> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
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
                'Select Your Role',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.verified_user,
                    color: Colors.black,
                  ),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: " Register as a Patient",
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                        TextSpan(text: ' '),
                        TextSpan(
                          text: 'HERE',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/registration');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                  Icon(
                    Icons.local_hospital,
                    color: Colors.black,
                  ),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: " Register as a Doctor",
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                        TextSpan(text: ' '),
                        TextSpan(
                          text: 'HERE',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/registrationDoctor');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              )

            ],
          ),
        )
    );
  }
}
