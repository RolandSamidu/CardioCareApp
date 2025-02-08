
import 'dart:convert';

import 'package:heart_app/models/record.dart';
import 'package:heart_app/constants/server.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordsService {
  static final instance = RecordsService._();

  RecordsService._();



  Future<List<Record>> getUserRecords(user) async {
    List<Record> records = [];
    if (user != null) {
      try {
        final apiUrl = Uri.parse('${ServerConfig.serverUrl}/model/all');
        final response = await http.get(
          apiUrl,
          headers: {'Content-Type': 'application/json'},
        );

        if(response.statusCode == 200){
          final List<dynamic> data = jsonDecode(response.body);
          records = data.map((record) => Record.fromJson(record)).toList();
          return records;
        }

      } catch(e) {
        print('An error occurred: $e');
      }
    } else {
      throw Exception('User is not authenticated and Records didn t save');
    }
    return records;
  }
}
