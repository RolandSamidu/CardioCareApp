import 'dart:io';
import 'package:heart_app/analysing_ecg.dart';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:heart_app/constants/server.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:heart_app/BottomNavigationBarWidget.dart';
import 'package:heart_app/analysing.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

import 'package:provider/provider.dart';

class ECGScreen extends StatefulWidget {
  @override
  _ECGScreenState createState() => _ECGScreenState();
}

class _ECGScreenState extends State<ECGScreen> {
  List<XFile>? _images = [];
  XFile? _image;
  String _predictedResult = "";
  String _date = "";
  String _time = "";
  String _user = "";
  String _disease_res = "";
  int currentIndex = 1;
  String cardio_pred = "";


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
      maxWidth: 2200,
      imageQuality: 100,
    );

    if (pickedFiles != null) {
      setState(() {
        _images!.clear();
        _images!.addAll(pickedFiles);
      });
    }
  }

  Future<void> Dignosis() async {
    if (_images!.isNotEmpty) {
      _image = _images!.first;
    }
    if (_image != null) {

      try {
        final uri = Uri.parse('${ServerConfig.serverUrl}/model/predict_ecg_test');
        final request = http.MultipartRequest('POST', uri)
          ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          setState(() {
            _date = getCurrentDate();
            _time = getCurrentTime();
            _predictedResult = response.body;
            final jsonResponse = jsonDecode(_predictedResult);

            if (jsonResponse.containsKey("prediction")) {
              _disease_res = jsonResponse["prediction"];
            }
          });
        }
      } catch (e) {
        setState(() {
          _predictedResult = "Error: $e";
        });
      }
    } else {
      setState(() {
        _predictedResult = "No image selected.";
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
                icon: Icon(Icons.logout, color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
              ),
            ],
            title: Text(
              'ECG Graph Test',
              style: TextStyle(color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
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
                                    "Check ECG Graphs",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color:  Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "Upload your ECG graphs here.",
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
                              'assets/ecg.png',
                              width: 100, // Adjust image width as needed
                              height: 100, // Adjust image height as needed
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      )
                  ),
                  SizedBox(height: 10,),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        _images != null && _images!.isNotEmpty
                            ? Image.file(
                          File(_images!.first.path),
                          height: 200.0,
                          width: 200.0,
                        )
                            :
                        Container(
                          decoration: BoxDecoration(
                            color: Color(int.parse(ThemeColors.themes['theme01']?['primary_accent']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                            border: Border.all(
                              color: Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/fileup.png',
                            height: 200.0,
                            width: 200.0,
                          ),
                        ),



                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        _getImageFromGallery();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(int.parse(ThemeColors.themes['theme01']?['highlight']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Select Photos'),
                    ),
                  ),
                  SizedBox(height: 70),
                  if (_images!.isNotEmpty)

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
                      onPressed: ()async {
                        await Dignosis();
                        if (_disease_res.isNotEmpty) {
                          print(_disease_res);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnalysingECGScreen(
                                ecgPred: _disease_res,
                                probability: 0
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
                      child: Text('Submit ECG Graph'),
                    ),
                  ),
                  SizedBox(height: 10),
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


