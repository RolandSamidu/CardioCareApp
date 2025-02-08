import 'package:heart_app/UserHistory.dart';
import 'package:heart_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heart_app/constants/server.dart';
import 'package:provider/provider.dart';

class PatientsScreen extends StatefulWidget {
  @override
  _PatientsScreenState createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<String> patientsUsernames = [];

  Future<void> fetchPatients() async {
    try {
      final userName = context.read<RegUser>().userName;
      final response = await http.get(Uri.parse('${ServerConfig.serverUrl}/user/get-patients-by-doctor?doctor_email=$userName'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('patients')) {
          dynamic patientsData = data['patients'];

          List<String> processedData = [];

          if (patientsData is Map<String, dynamic>) {
            patientsData.forEach((patientId, patientData) {
              if (patientData is Map<String, dynamic>) {
                processedData.add(patientId);
              }
            });
          } else {
            throw Exception('Invalid data format: Patients data is not a Map');
          }
          setState(() {
            patientsUsernames = processedData;
          });
        } else {
          throw Exception('Invalid data format: "patients" key not found');
        }
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      print('Error fetching patients: $e');
      // Handle the error as needed
    }
  }



  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Patients List', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: patientsUsernames.length,
        itemBuilder: (context, index) {
          final patientUsername = patientsUsernames[index];
          return Card(
            child: ListTile(
              subtitle: Text("User"),
              title: Text(patientUsername ?? 'N/A'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserHistoryScreen(
                      username: patientUsername,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
