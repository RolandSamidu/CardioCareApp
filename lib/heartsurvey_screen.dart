import 'dart:io';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/resultsheart_screen.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:heart_app/BottomNavigationBarWidget.dart';
import 'package:heart_app/analysing.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

import 'package:provider/provider.dart';

class HeartSurveyScreen extends StatefulWidget {
  @override
  _HeartSurveyScreenState createState() => _HeartSurveyScreenState();
}

class _HeartSurveyScreenState extends State<HeartSurveyScreen> {
  List<XFile>? _images = [];
  XFile? _image;
  String _predictedResult = "";
  String _date = "";
  String _time = "";
  String _user = "";
  String _disease_res = "";
  int currentIndex = 1;


  // For Cardio Prediction
  double _age = 0;
  int _gender = 1; //0 - female 1 - male
  int _cp = 0;
  double _bp = 90;
  int _fbs = 0;
  int _recg = 0;
  double _cole = 120;
  double _hrate = 70;
  int _exe = 0;
  double _old = 0;  // 1 - 3 only
  double _slope = 0;
  double _vessel = 0;
  int _thal = 0;
  String cardio_pred = "";
  double probability = 0;


  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/my-profile');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/my-history');
        break;
    }
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;
    return '$hour:$minute:$second';
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String date = "";
    int year = now.year;
    int month = now.month;
    int day = now.day;
    DateTime currentDate = DateTime(year, month, day);
    date = currentDate.toString();
    return date;
  }

  void _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 800,
      imageQuality: 100,
    );

    if (pickedFiles != null) {
      setState(() {
        _images!.clear();
        _images!.addAll(pickedFiles);
      });
    }
  }

  Future<void> createRecord() async {
    final apiUrl = Uri.parse('${ServerConfig.serverUrl}/model/save');

    try {
      String firstImageFilename = _images!.isNotEmpty ? _images!.first.path.split('/').last : '';
      final requestData = {
        "user": _user,
        "prediction": _disease_res,
        "Date": _date,
        "Time": _time,
        "Files": [firstImageFilename],
        "DoctorVeri": 'To Be Confirm'
      };

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print('Record created successfully');
      } else {
        print('Failed to create record. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> predictCardio(Map<String, dynamic> features) async {
    final apiUrl = Uri.parse('${ServerConfig.serverUrl}/patient/predict_heart');
    try {
      print(features);
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(features),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        print(result);
        if(result.isNotEmpty){
          cardio_pred = result['prediction'];
          probability = result['probability']??0.0;
        }

        return result;
      } else {
        // Handle the error
        print('Failed to make predictions. Status code: ${response.statusCode}');
        return {'error': 'Failed to make predictions'};
      }
    } catch (e) {
      // Handle the exception
      print('Error making predictions: $e');
      return {'error': 'Error making predictions'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegUser>(
      builder: (context, user, child) {
        _user = user.userName;
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
                icon: Icon(Icons.logout, color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000)),
              ),
            ],
            title: Text(
              'Heart Disease Diagnosis Check',
              style: TextStyle(color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000)),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  Center(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(16.0),
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Heart Disease Checkup",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color:  Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "Fill given form to predict heart disease probability.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10, // Adjust the width of the gap between text and image
                            ),
                            // Replace the Image.asset with your desired image
                            Image.asset(
                              'assets/heart.png',
                              width: 100, // Adjust image width as needed
                              height: 100, // Adjust image height as needed
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      )
                  ),
                  SizedBox(height: 10),
                  if (_images!.isNotEmpty) Text(
                    'Files Count: ${_images!.length}',
                    style: TextStyle(color: Colors.black),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Fill below information about Patient',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _gender,
                          items: [
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Male'),
                            ),
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Female'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _gender = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Gender',
                          ),
                        ),
                        SizedBox(height: 16),
                        Slider(
                          value: _age,
                          min: 0,
                          max: 100,
                          onChanged: (double value) {
                            setState(() {
                              _age = value;
                            });
                          },
                          divisions: 100, // The number of divisions for the slider
                          label: _age.round().toString(),
                        ),
                        Text(
                          'Age: ${_age.round()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Slider(
                          value: _bp,
                          min: 0,
                          max: 400,
                          onChanged: (double value) {
                            setState(() {
                              _bp = value;
                            });
                          },
                          divisions: 100, // The number of divisions for the slider
                          label: _bp.round().toString(),
                        ),
                        Text(
                          'Blood Pressure: ${_bp.round()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Slider(
                          value: _cole,
                          min: 100,
                          max: 400,
                          onChanged: (double value) {
                            setState(() {
                              _cole = value;
                            });
                          },
                          divisions: 100, // The number of divisions for the slider
                          label: _cole.round().toString(),
                        ),
                        Text(
                          'Cholestoral: ${_cole.round()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _fbs,
                          items: [
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('No I haven t got'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Yes I have'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _fbs = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Fasting Blood Sugar (Higher than 120mg/dl)',
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _cp,
                          items: [
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('No Pain'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Level 01'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('Level 02'),
                            ),
                            DropdownMenuItem<int>(
                              value: 3,
                              child: Text('Level 03'),
                            ),
                            DropdownMenuItem<int>(
                              value: 4,
                              child: Text('Level 04'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _cp = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Chest Pain Type',
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _recg,
                          items: [
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Level 00'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Level 01'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('Level 02'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _recg = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Resting Electrocardiographic result',
                          ),
                        ),
                        SizedBox(height: 2),
                        Slider(
                          value: _hrate,
                          min: 70,
                          max: 250,
                          onChanged: (double value) {
                            setState(() {
                              _hrate = value;
                            });
                          },
                          divisions: 100, // The number of divisions for the slider
                          label: _hrate.round().toString(),
                        ),
                        Text(
                          'Maximum Heart Rate Achieved: ${_hrate.round()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Slider(
                          value: _old,
                          min: 0,
                          max: 10,
                          onChanged: (double value) {
                            setState(() {
                              _old = value;
                            });
                          },
                          divisions: 100, // The number of divisions for the slider
                          label: _old.round().toString(),
                        ),
                        Text(
                          'Old Peak: ${_old.round()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Slider(
                          value: _slope,
                          min: 0,
                          max: 10,
                          onChanged: (double value) {
                            setState(() {
                              _slope = value;
                            });
                          },
                          divisions: 100, // The number of divisions for the slider
                          label: _slope.round().toString(),
                        ),
                        Text(
                          'Slope of Peak exercise ST Segment: ${_slope.round()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _exe,
                          items: [
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('No'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Yes'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _exe = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Exercise induced Angina',
                          ),
                        ),
                        SizedBox(height: 2),
                        Slider(
                          value: _vessel,
                          min: 0,
                          max: 3,
                          onChanged: (double value) {
                            setState(() {
                              _vessel = value;
                            });
                          },
                          divisions: 100, // The number of divisions for the slider
                          label: _vessel.round().toString(),
                        ),
                        Text(
                          'Number of Major Vessels: ${_vessel.round()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        DropdownButtonFormField<int>(
                          value: _thal,
                          items: [
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Normal'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Fixed Defect'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('Reversable Defect'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _recg = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Thal Value',
                          ),
                        ),
                        SizedBox(height: 2),
                        ]
                    )
                  ),

                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.all(15),
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
                      onPressed: () async {
                        final obj = {
                          "AGE": _age,
                          "SEX": _gender,
                          "CP": _cp,
                          "TRETBPS": _bp,
                          "CHOLESTROL": _cole,
                          "FBS": _fbs,
                          "RESTECG": _recg,
                          "THALACH": _hrate,
                          "EXANG": _exe,
                          "OLDPEAK": _old,
                          "SLOPE": _slope,
                          "CS": _vessel,
                          "THAL": _thal,
                        };
                        await predictCardio(obj);

                        if (cardio_pred.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnalysingScreen(
                                  cardioPred: cardio_pred,
                                  probability: probability
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, // Transparent background
                        elevation: 0, // No shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded edges
                        ),
                      ),
                      child: Text('Diagnosis Heart Disease'),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
          bottomNavigationBar: MyBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTabTapped,
          ),
        );
      },
    );
  }
}


