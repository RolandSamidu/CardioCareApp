import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/map_window2.dart';
import 'package:heart_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heart_app/constants/server.dart';
import 'package:provider/provider.dart';

class PharmaciesScreen extends StatefulWidget {
  @override
  _PharmaciesScreenState createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  List<Map<String, dynamic>> pharmacies = [];

  Future<void> fetchPharmacies() async {
    try {
      final response = await http.get(Uri.parse('${ServerConfig.serverUrl}/pharmacies/get_pharmacies_comments'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('pharmacies')) {
          dynamic pharmaciesData = data['pharmacies'];

          List<Map<String, dynamic>> processedData = [];

          if (pharmaciesData is List<dynamic>) {
            processedData = List<Map<String, dynamic>>.from(pharmaciesData);
          } else {
            throw Exception('Invalid data format: Pharmacies data is not a List');
          }
          setState(() {
            pharmacies = processedData;
          });
        } else {
          throw Exception('Invalid data format: "pharmacies" key not found');
        }
      } else {
        throw Exception('Failed to load pharmacies');
      }
    } catch (e) {
      print('Error fetching pharmacies: $e');
      // Handle the error as needed
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPharmacies();
  }

  @override
  Widget build(BuildContext context) {
    pharmacies.sort((a, b) {
      final double scoreA = (a['sentiment_score']['average_polarity'] as num).toDouble();
      final double scoreB = (b['sentiment_score']['average_polarity'] as num).toDouble();
      return scoreB.compareTo(scoreA);
    });
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
        title: Text('Pharmacies List', style: TextStyle(color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        "Find Pharmacies",
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
                  'assets/pharmacy.png',
                  width: 100, // Adjust image width as needed
                  height: 100, // Adjust image height as needed
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          Expanded(
            child: pharmacies.length==0 ?
            Center(
              child: Container(
                width: 100, // Adjust the width as needed
                height: 100, // Adjust the height as needed
                child: Image.asset(
                  'assets/pulse.gif',
                ),
              ),
            )
                :ListView.builder(
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final pharmacy = pharmacies[index];
                return SizedBox(
                  child: Container(
                    child: Card(
                      elevation: 5,
                      color: Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Ensure card has the same border radius as container
                      ),
                      child: ListTile(
                        subtitle: Row(
                          children: [
                            Text(
                              "Likability Points: ${pharmacy['sentiment_score']['average_polarity'].toStringAsFixed(2)}", // Limit likability points to two decimal points
                              style: TextStyle(
                                color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000).withOpacity(0.8),
                              ),
                            ),
                            SizedBox(width: 10),
                            // Show stars based on likability points
                            Row(
                              children: List.generate(5, (index) {
                                double rating = (index + 1) / 5 * 2 - 1; // Map index to likability rating (-1 to 1)
                                if (pharmacy['sentiment_score']['average_polarity'] >= rating) {
                                  return Icon(Icons.star, color: Colors.yellow); // Full star
                                } else {
                                  return Icon(Icons.star_border, color: Colors.yellow); // Outline star
                                }
                              }),
                            ),
                          ],
                        ),
                        title: Text(
                          pharmacy['name'] ?? 'N/A',
                          style: TextStyle(
                            color: Color(int.parse(ThemeColors.themes['theme01']?['secondary_font']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Map2Screen(initialLocation: LatLng(pharmacy['location']['lat'], pharmacy['location']['lng']), name: pharmacy['name'] ?? 'N/A',)),
                          );
                        },
                      ),



                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}

