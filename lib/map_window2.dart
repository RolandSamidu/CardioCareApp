import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heart_app/constants/colors.dart';
import 'package:heart_app/constants/server.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;


class Map2Screen extends StatefulWidget {
  final LatLng initialLocation;
  final String name;

  Map2Screen({required this.initialLocation, required this.name});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<Map2Screen> {
  Completer<GoogleMapController> _controller = Completer();

  late LatLng _currentLocation;
  late LatLng destination = LatLng(6.8018, 79.9227);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  String comment = '';

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void getPolyPath() async {
    PolylinePoints polylineWPoints = PolylinePoints();
    PolylineResult result = await polylineWPoints.getRouteBetweenCoordinates(
      ServerConfig.gmap_api,
      PointLatLng(_currentLocation.latitude, _currentLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) => polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((value) {
      setState(() {
        currentLocation = value;
      });
    });

  }

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    getCurrentLocation();
    getPolyPath();
  }

  // Method to open comments on the selected pharmacy
  void _openComments() {
    // Navigate to the screen or show a dialog to display comments and allow users to send comments
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pharmacy Comments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display comments here
              // Text area for users to input comments
              TextField(
                decoration: InputDecoration(labelText: 'Enter your comment'),
                onChanged: (value) {
                  setState(() {
                    comment = value;
                  });
                },
              ),
              SizedBox(height: 10),
              // Send button
              ElevatedButton(
                onPressed: () async {
                  final requestData = {
                    "pharmacy_id": widget.name,
                    "comment_text": comment
                  };
                  final response = await http.post(
                    Uri.parse('${ServerConfig.serverUrl}/pharmacies/post_comment'),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(requestData),
                  );

                  if (response.statusCode == 200) {
                    // Request was successful
                    print('Comment created successfully');
                    Navigator.of(context).pop(true);
                  } else {
                    // Request failed
                    print('Failed to create record. Status code: ${response.statusCode}');
                  }

                },
                child: Text('Send'),
              ),
            ],
          ),
        );
      },
    );
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
        title: Text('Locate Pharmacy'),
      ),
      body: currentLocation == null
          ? Center(
        child: Container(
          width: 100,
          height: 100,
          child: Image.asset('assets/pulse.gif'),
        ),
      )
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 13.0,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('Path'),
            points: polylineCoordinates,
            color: Color(int.parse(ThemeColors.themes['theme01']?['secondary']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000),
          ),
        },
        markers: {
          Marker(
            markerId: MarkerId('Pharmacy Location'),
            position: _currentLocation,
            infoWindow: InfoWindow(title: 'Your Destination'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
          Marker(
            markerId: MarkerId('My Location'),
            position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            infoWindow: InfoWindow(title: 'My Location'),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openComments,
        child: Icon(Icons.comment),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

