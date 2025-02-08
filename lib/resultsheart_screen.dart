import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/probabilityinstructions.dart';
import 'package:heart_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heart_app/login.dart';

class ResultsHeartScreen extends StatelessWidget {
  final String cardioPred;
  final double probability;

  ResultsHeartScreen({required this.cardioPred, required this.probability});

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to send the verification request?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  String getInstructions(double probability) {
    for (var rangeInfo in ProbabilityInstructions.probabilityRange) {
      if ((probability*100) < 5 && rangeInfo['range'] == 'lower than 5%') {
        return (rangeInfo['instruction'] as List<String>).join('\n\n');
      } else if ((probability*100) >= 5 && (probability*100) < 10 && rangeInfo['range'] == 'between 5 and 10%') {
        return (rangeInfo['instruction'] as List<String>).join('\n\n');
      } else if ((probability*100) >= 10 && (probability*100) < 20 && rangeInfo['range'] == 'between 10 and 20%') {
        return (rangeInfo['instruction'] as List<String>).join('\n\n');
      } else if ((probability*100) >= 20 && (probability*100) < 30 && rangeInfo['range'] == 'between 20 and 30%') {
        return (rangeInfo['instruction'] as List<String>).join('\n\n');
      } else if ((probability*100) >= 30 && rangeInfo['range'] == 'equal or more than 30%') {
        return (rangeInfo['instruction'] as List<String>).join('\n\n');
      }
    }
    return '';
  }

  Color getColor(double probability) {
    if (probability < 0.5) {
      return Color(0xFFbdc3c7);
    } else if (probability >= 0.5 && probability < 0.7) {
      return Color(0xFF2ecc71);
    } else if (probability >= 0.7 && probability < 0.8) {
      return Color(0xFFf39c12);
    } else if (probability >= 0.8 && probability < 0.9) {
      return Color(0xFFe67e22);
    } else {
      return Color(0xFFe74c3c); 
    }
  }



  Future<void> _loadRecord(BuildContext context) async {
    try {
      final userName = context.read<RegUser>().userName;
      final record = await getRecord(userName);

      if (record != null && record['success'] == true) {
        final doctorData = record['record']['doctor'];

        if (doctorData != null) {
          final doctorContact = doctorData['contact'] ?? '';
          print('Doctor Contact: $doctorContact');

          bool confirmation = await _showConfirmationDialog(context);
          if (confirmation) {
            sendOTP(doctorContact, "One of your patient $userName having and holds larger probability of having heart attack.");
          }
        } else {
          print('Doctor data not found in the record.');
        }
      } else {
        print('Failed to fetch record data or record does not indicate success.');
      }
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
          'Heart Disease Checkup Results',
          style: TextStyle(
            color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Results of Heart Disease Survey:',
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
                        cardioPred,
                        style: TextStyle(
                          fontSize: 20,
                          color:Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Probability (%)",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                        ),
                      ),
                      Text(
                          (probability * 100).toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Text(
                'Instructions:',
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
                      getColor(probability),
                      Color(int.parse(ThemeColors.themes['theme01']?['primary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.0), // Adjust radius as needed
                ),
                padding: EdgeInsets.all(20.0), // Padding around the text
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getInstructions(probability),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20,),

              Spacer(),
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