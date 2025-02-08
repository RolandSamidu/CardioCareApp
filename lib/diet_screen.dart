import 'dart:convert';
import 'dart:io';

import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/probabilityinstructions.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/dietreults_screen.dart';
import 'package:heart_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:heart_app/login.dart';

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  List<XFile>? _images = [];
  XFile? _image;
  String _predictedResult = "";

  String getInstructions(double probability) {
    return '';
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

  Future<void> submitPlan() async {
    if(_images!.isNotEmpty){
      _image = _images!.first;
    }

    try {
      final uri = Uri.parse('${ServerConfig.serverUrl}/diets/predict-foods-upload');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          _predictedResult = response.body;
          final jsonResponse = jsonDecode(_predictedResult);

          if (jsonResponse.containsKey("prediction")) {
            _predictedResult = jsonResponse["prediction"];
          }
        });
      }

    } catch (e) {
      setState(() {
        _predictedResult = "Error: $e";
      });
    }
  }

  Future<void> _loadRecord(BuildContext context) async {
    try {
      // Implement your logic here for loading the record
    } catch (e) {
      print('Error loading record: $e');
      // Handle the error as needed
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
            icon: Icon(
              Icons.logout,
              color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
            ),
          ),
        ],
        title: Text(
          'Diet Plan',
          style: TextStyle(
            color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Plan Your Diet",
                                style: TextStyle(
                                    fontSize: 24,
                                    color:  Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                "Enter a Image of your Meal Below",
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
                          'assets/meal.png',
                          width: 100, // Adjust image width as needed
                          height: 100, // Adjust image height as needed
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  )
              ),
              SizedBox(height: 5,),
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
                        : Container(
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
              SizedBox(height: 5,),
              Text(
                'Observations:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse(ThemeColors.themes['theme01']?['font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(int.parse(ThemeColors.themes['theme01']?['shadow']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                      Color(int.parse(ThemeColors.themes['theme01']?['primary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.0), // Adjust radius as needed
                ),
                padding: EdgeInsets.all(10.0), // Padding around the text
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Parse the JSON string into a map and iterate through its entries
                    if (_predictedResult.isNotEmpty)
                      ...jsonDecode(_predictedResult).entries.map((entry) {
                        return Text(
                          '${entry.key}: x ${entry.value}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        );
                      }).toList(),
                    (_predictedResult.isNotEmpty)
                        ? Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DietResultsScreen(
                                  predictedResult: _predictedResult
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(int.parse(ThemeColors.themes['theme01']?['highlight']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('More Details'),
                      ),
                    )
                        : SizedBox(),

                  ],
                ),
              ),
              Spacer(),

              if (_images!.isNotEmpty)

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
                    onPressed: ()async {
                      await submitPlan();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent, // Transparent background
                      elevation: 0, // No shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded edges
                      ),
                    ),
                    child: Text('Submit Diet Image'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
