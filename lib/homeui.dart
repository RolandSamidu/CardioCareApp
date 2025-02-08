import 'package:flutter/material.dart';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/BottomNavigationBarWidget.dart';
import 'package:heart_app/myrecords_screen.dart';
import 'package:heart_app/profile.dart';
import 'package:heart_app/widgets/icon_widget.dart';
import 'package:provider/provider.dart';
import 'package:heart_app/models/user.dart';
import 'package:heart_app/models/record.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class homeScreen extends StatefulWidget {
  homeScreen();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homeScreen> {
  int currentIndex = 0;
  List<TableRow> recordRows = [];
  Map<String, Map<String, String>> progressData = {};

  @override
  void initState() {
    super.initState();
  }



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

  @override
  Widget build(BuildContext context) {
    return Consumer<RegUser>(
      builder: (context, user, child) {
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
              user.name+'- '+user.role,
              style: TextStyle(color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
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
                SizedBox(height: 15),


                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          email: user.userName,
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
                  child: Text('My Profile'),
                ),
                SizedBox(height: 25),
                Text(
                  'Dashboard Options',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate to Dashboard screen
                              Navigator.pushNamed(context, '/heart-patient');
                            },
                            child: IconWithText(icon: Icons.monitor_heart, text: 'Patient Survey'),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to Dashboard screen
                              Navigator.pushNamed(context, '/ecg');
                            },
                            child: IconWithText(icon: Icons.area_chart, text: 'ECG Check'),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to Dashboard screen
                              Navigator.pushNamed(context, '/pharmacies');
                            },
                            child: IconWithText(icon: Icons.medical_information, text: 'Medicines'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate to Dashboard screen
                              Navigator.pushNamed(context, '/diet-plan');
                            },
                            child: IconWithText(icon: Icons.next_plan, text: 'Dietitian Plan'),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     // Navigate to Dashboard screen
                          //     Navigator.pushNamed(context, '/map');
                          //   },
                          //   child: IconWithText(icon: Icons.map, text: 'Pharmacies'),
                          // ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to Dashboard screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MYHistoryScreen(
                                      userEmail: context.read<RegUser>().userName,
                                  ),
                                ),
                              );
                              Navigator.pushNamed(context, '/my-history');
                            },
                            child: IconWithText(icon: Icons.calendar_today, text: 'My History'),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: user.role=='Patient'? MyBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTabTapped,
          ):null,
        );
      },
    );
  }
}