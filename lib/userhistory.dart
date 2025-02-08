import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heart_app/BottomNavigationBarWidget.dart';
import 'package:provider/provider.dart';
import 'package:heart_app/models/user.dart';
import 'package:heart_app/constants/server.dart';

class UserHistoryScreen extends StatefulWidget {
  final String username;

  UserHistoryScreen({required this.username});

  @override
  _UserHistoryScreenState createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  int currentIndex = 2;
  Map<String, Map<String, String>> progressData = {};

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/camdiagnosis');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/history');
        break;
    }
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        '${ServerConfig.serverUrl}/model/previous?name=${widget.username}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      Map<String, Map<String, String>> processedData = Map();
      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          Map<String, String> innerData = Map();
          value.forEach((innerKey, innerValue) {
            if (innerValue is String) {
              innerData[innerKey] = innerValue;
            }
          });
          processedData[key] = innerData;
        }
      });

      setState(() {
        progressData = processedData;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<RegUser>().updateUserName('', '', '');
              Navigator.pushNamed(context, '/login');
            },
            icon: Icon(Icons.logout, color: Colors.black),
          ),
        ],
        title: Text('User Diagnosis History', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/patients');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: DataTable(
            headingRowHeight: 50,
            dataRowHeight: 50,
            columns: <DataColumn>[
              DataColumn(
                label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Diagnosis', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: progressData.entries.map((entry) {
              final Map<String, String> values = entry.value;
              final isOddRow = progressData.entries.toList().indexOf(entry) % 2 == 1;

              return DataRow(
                color: MaterialStateProperty.all((values['DoctorVeri'] == "To Be Confirm") ? Colors.yellow : Colors.blue),
                cells:  <DataCell>[
                  DataCell(Text(values['Date'] ?? 'N/A')),
                  DataCell(Text(values['prediction'] ?? 'N/A')),
                  DataCell(Text(values['DoctorVeri'] ?? 'N/A')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
