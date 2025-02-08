import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/server.dart';
import 'package:heart_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class MYHistoryScreen extends StatefulWidget {
  final String userEmail;

  MYHistoryScreen({required this.userEmail});

  @override
  _MYHistoryScreenState createState() => _MYHistoryScreenState();
}

class _MYHistoryScreenState extends State<MYHistoryScreen> {
  List<MedicalRecord> medicalRecords = [];
  bool showTable = false;

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
    // Start a timer to show the table after 10 seconds
    Timer(Duration(seconds: 10), () {
      setState(() {
        showTable = true;
      });
    });
  }

  Future<void> _fetchMedicalRecords() async {
    print(widget.userEmail);
    try {
      final response = await http.post(
          Uri.parse(ServerConfig.serverUrl+'/medical-records/get_medical_records_by_user_email'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_email': widget.userEmail})
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          medicalRecords = List<MedicalRecord>.from(data['medical_records']
              .map((record) => MedicalRecord.fromJson(record)));
        });
        print(medicalRecords);
      } else {
        throw Exception('Failed to load medical records');
      }
    } catch (e) {
      print('Error fetching medical records: $e');
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
          'Medical Records',
          style: TextStyle(color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
        ),
      ),
      body: Center(
        child: !showTable
            ? Container(
          width: 100, // Adjust the width as needed
          height: 100, // Adjust the height as needed
          child: Image.asset(
            'assets/pulse.gif',
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
              padding: EdgeInsets.all(16.0), // Padding around the text
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Medical History",
                          style: TextStyle(
                              fontSize: 24,
                              color:  Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          "Find Pharmacies around your location.",
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
                    'assets/chart.png',
                    width: 100, // Adjust image width as needed
                    height: 100, // Adjust image height as needed
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <ChartSeries>[
                  LineSeries<MedicalRecord, String>(
                    dataSource: medicalRecords,
                    xValueMapper: (MedicalRecord record, _) =>
                        DateFormat('yyyy-MM-dd').format(record.recordedDate),
                    yValueMapper: (MedicalRecord record, _) =>
                        record.severity.index.toDouble(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class MedicalRecord {
  final DateTime recordedDate;
  final Severity severity;

  MedicalRecord({required this.recordedDate, required this.severity});

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    // Check if the required fields are present in the JSON
    if (!json.containsKey('recorded_date') || !json.containsKey('severity')) {
      throw FormatException("Invalid JSON format: missing required fields");
    }

    // Parse the recorded date
    String? recordedDateString = json['recorded_date'];
    if (recordedDateString == null) {
      throw FormatException("Invalid JSON format: 'recorded_date' is null");
    }
    DateTime recordedDate = DateFormat('yyyy-MM-dd').parse(recordedDateString);
    if (recordedDate == null) {
      throw FormatException("Invalid 'recorded_date' format: $recordedDateString");
    }

    // Parse the severity
    int? severityIndex = json['severity'];
    if (severityIndex == null) {
      throw FormatException("Invalid JSON format: 'severity' is null");
    }
    Severity severity;
    switch (severityIndex) {
      case 0:
        severity = Severity.normal;
        break;
      case 1:
        severity = Severity.medium;
        break;
      case 2:
        severity = Severity.high;
        break;
      default:
        throw FormatException("Invalid severity index: $severityIndex");
    }

    return MedicalRecord(
      recordedDate: recordedDate,
      severity: severity,
    );
  }
}

enum Severity { normal, medium, high }
