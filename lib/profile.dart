import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserProfileScreen extends StatelessWidget {
  final String email;

  UserProfileScreen({required this.email});

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final response =
    await http.get(Uri.parse(ServerConfig.serverUrl + '/user/get?email=$email'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user details');
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
          'User Profile',
          style: TextStyle(
            color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
          ),
        ),
      ),
      body: FutureBuilder(
        future: getUserByEmail(email),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading screen while fetching data
            return Center(
              child: Container(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/pulse.gif',
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // Display an error message if data retrieval fails
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // Display user details once data is loaded
            final userData = snapshot.data!['user'];
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userData['email']}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 15),
                        Text('Email: ${userData['email']}'),
                        SizedBox(height: 5),
                        Text('Age: ${userData['age']}'),
                        SizedBox(height: 5),
                        Text('Contact Number: ${userData['contact']}'),
                        SizedBox(height: 5),
                        Text('Previous Issues: ${userData['previous']}'),
                        // Add more user details as needed
                      ],
                    ),
                  ),
                  // Add more user details as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
