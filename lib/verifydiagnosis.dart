import 'dart:convert';

import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heart_app/login.dart';
import 'package:http/http.dart' as http;

class VerificationScreen extends StatelessWidget {
  final String diseaseResult;

  VerificationScreen({required this.diseaseResult});

  Future<bool> _showConfirmationDialog(BuildContext context, String disease) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you agree with the given prediction? Then save it to your medical record?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                final requestData = {
                  "user_email": context.read<RegUser>().userName,
                  "condition": disease,
                  "severity": determineSeverityLevel(disease),
                  "comment": "Patient needs immediate attention."
                };
                final response = await http.post(
                  Uri.parse('${ServerConfig.serverUrl}/medical-records/create_medical_record'),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(requestData),
                );

                if (response.statusCode == 200) {
                  // Request was successful
                  print('Medical Record created successfully');
                  Navigator.of(context).pop(true);
                  Navigator.pushNamed(context, '/');
                } else {
                  // Request failed
                  print('Failed to create record. Status code: ${response.statusCode}');
                }
              },
            ),
          ],
        );
      },
    );
  }

  String determineSeverityLevel(String disease) {
    if (disease == 'You ECG corresponds to Myocardial Infarction' || disease == 'Stroke') {
      return 'High';
    } else if (disease == 'You ECG corresponds to History of Myocardial Infarction' || disease == 'You ECG corresponds to Abnormal Heartbeat') {
      return 'Medium';
    } else {
      return 'Normal';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<RegUser>().updateUserName('', '', '');
              Navigator.pushNamed(context, '/login');
            },
            icon: Icon(Icons.logout, color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
          ),
        ],
        title: Text(
          'Verification',
          style: TextStyle(color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diagnosis Result from Previous Screen:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse(ThemeColors.themes['theme01']?['font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                        Color(int.parse(ThemeColors.themes['theme01']?['secondary_accent']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10.0), // Padding around the text
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Prediction",
                        style: TextStyle(
                          fontSize: 16,
                          color:  Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                        ),
                      ),
                      Text(
                        diseaseResult,
                        style: TextStyle(
                          fontSize: 20,
                          color:Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              // Center(
              //   child: Text(
              //     diseaseResult,
              //     style: TextStyle(
              //       fontSize: 16,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              // Center(
              //   child: Text(
              //     cardioPred,
              //     style: TextStyle(
              //       fontSize: 20,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              // SizedBox(height: 20,),

              Spacer(),
              OutlinedButton(
                onPressed: () async {
                  bool confirmed = await _showConfirmationDialog(context, diseaseResult);
                  if (confirmed) {
                    // Navigate to the home screen
                    Navigator.pushNamed(context, '/');
                  }
                },
                child: Text('Save to Medical Record'),
              ),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                      Color(int.parse(ThemeColors.themes['theme01']?['secondary_accent']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                    ],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent, // Transparent background
                    elevation: 0, // No shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded edges
                    ),
                  ),
                  child: Text('To Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}