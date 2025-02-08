import 'package:heart_app/login.dart';
import 'package:heart_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heart_app/constants/server.dart';
import 'package:provider/provider.dart';

class DoctorsScreen extends StatefulWidget {
  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Map<String, String>> doctorsList = [];
  Map<String, String>? selectedDoctor;
  var doctorData = null;

  void selectDoctor(Map<String, String>? doctor) {
    setState(() {
      selectedDoctor = doctor;
    });
  }

  void confirmChoice() {
    final userName = context.read<RegUser>().userName;
    final apiUrl =
    Uri.parse('${ServerConfig.serverUrl}/user/create-update-record');
    if (selectedDoctor != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmation"),
            content: Text("You have selected ${selectedDoctor!['name']}."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async{
                  try {
                    final requestData = {
                      "patient_email": userName,
                      "doctor": selectedDoctor,
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
                      print('Recordr created successfully');
                    } else {
                      // Request failed
                      print('Failed to create Record. Status code: ${response.statusCode}');
                    }
                  } catch (e) {
                    print('An error occurred: $e');
                  }
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/', arguments: selectedDoctor);
                },
                child: Text("Confirm"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchDoctors() async {
    final userName = context.read<RegUser>().userName;
    final response = await http.get(Uri.parse('${ServerConfig.serverUrl}/user/get-doctors'));
    final record = await getRecord(userName);

    if (record != null && record['success'] == true) {
      print(record['record']['doctor']);
      setState(() {
        doctorData = record['record']['doctor'];
      });
    }

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);

      if (data is Map<String, dynamic> && data.containsKey('doctors')) {
        final List<dynamic> doctorsData = data['doctors'];
        List<Map<String, String>> processedData = [];

        for (final dynamic item in doctorsData) {
          if (item is Map<String, dynamic>) {
            Map<String, String> innerData = Map();
            item.forEach((innerKey, innerValue) {
              if (innerValue is String) {
                innerData[innerKey] = innerValue;
              }
            });
            processedData.add(innerData);
          }
        }

        // Remove items with matching email from doctorsList
        doctorsList.removeWhere((item) => doctorData['email'] == item['email']);

        setState(() {
          doctorsList.addAll(processedData);
        });
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Doctors List', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DataTable(
                headingRowHeight: 50,
                dataRowHeight: 50,
                columns: <DataColumn>[
                  DataColumn(
                    label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Qualified', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: doctorsList.map((values) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(values['name'] ?? 'N/A')),
                      DataCell(Text(values['qualification'] ?? 'N/A')),
                      DataCell(Text(values['email'] ?? 'N/A')),
                    ],
                    onSelectChanged: (isSelected) {
                      selectDoctor(isSelected! ? values : null);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              if (selectedDoctor != null)
                Center(
                  child: Text(
                    "Selected Doctor: ${selectedDoctor!['name']} (${selectedDoctor!['qualification']})",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

              SizedBox(height: 20),
              if (doctorData != null)
                Text("You Already Selected: ${doctorData['name']} as your Doctor"),
              ElevatedButton(
                onPressed: () {
                  confirmChoice();
                },
                child: Text("Confirm Your Choice"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
