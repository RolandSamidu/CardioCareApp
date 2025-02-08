import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DiagnosisScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<DiagnosisScreen> {
  File? _image;
  String _predictedResult = "";

  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future Dignosis() async {
    if (_image != null) {
      final uri = Uri.parse(
          'https://1880-112-134-168-221.ngrok-free.app/model/uploadoriginalcompatible');
      final request = http.MultipartRequest('POST', uri)
        ..files
            .add(await http.MultipartFile.fromPath('my_image', _image!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _predictedResult = response.body;
        });
      }
    } else {
      setState(() {
        _predictedResult = "No image selected.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('ECG Diagnosis'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                _image == null
                    ? Text('Select an image.')
                    : Image.file(_image!,
                        height: 200.0,
                        width: 200.0),
                ElevatedButton(
                  onPressed: getImage,
                  child: Text('Select Image'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Dignosis();
                  },
                  child: Text('Diagnosis'),
                ),
                Text('Diagnosis: $_predictedResult'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
