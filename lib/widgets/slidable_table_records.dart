import 'package:heart_app/services/records_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:heart_app/models/record.dart';

class SlidableTableUserRecordsWidget extends StatefulWidget {
  final String userName;
  SlidableTableUserRecordsWidget({super.key, required this.userName});

  @override
  _SlidableTableUserRecordsWidgetState createState() => _SlidableTableUserRecordsWidgetState();
}

class _SlidableTableUserRecordsWidgetState extends State<SlidableTableUserRecordsWidget> {
  List<Record> userRecords = [];

  @override
  void initState() {
    super.initState();
    loadUserRecords(widget.userName);
  }

  Future<void> loadUserRecords(user) async {
    try {
      userRecords = await RecordsService.instance.getUserRecords(user);
      setState(() {});
    } catch (e) {
      // Handle the exception, e.g., show an error message.
      print('Error loading user records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: userRecords.length,
      itemBuilder: (context, index) {
        final userRecord = userRecords[index];
        final isOddRow = index % 2 == 1;

        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            color: isOddRow ? Colors.white : Colors.transparent,
            child: ListTile(
              title: Text("Date: ${userRecord.date}"),
              subtitle: Text("Date: ${userRecord.prediction}"),
              tileColor: isOddRow ? Colors.white : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          secondaryActions: [
            IconSlideAction(
              caption: 'Edit',
              color: Colors.blue,
              icon: Icons.edit,
              onTap: () {
                // Implement your edit action here
              },
            ),
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                // Implement your delete action here
              },
            ),
          ],
        );
      },
    );
  }
}