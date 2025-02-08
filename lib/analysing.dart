import 'package:flutter/material.dart';
import 'package:heart_app/resultsheart_screen.dart';
import 'dart:io';
import 'package:heart_app/verifydiagnosis.dart';

class AnalysingScreen extends StatefulWidget {
  final String cardioPred;
  final double probability;

  AnalysingScreen({required this.cardioPred, required this.probability});

  @override
  _AnalysingScreenState createState() => _AnalysingScreenState();
}

class _AnalysingScreenState extends State<AnalysingScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 10), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsHeartScreen(
            cardioPred: widget.cardioPred,
              probability: widget.probability
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              child: Image.asset(
                'assets/pulse.gif',
              ),
            ),
            // Text(
            //   'We are analyzing your Survey Information. Keep waiting to get details your Heart Condition...',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.black.withOpacity(0.88),
            //     fontSize: 19,
            //     fontFamily: 'Poppins',
            //     fontWeight: FontWeight.w700,
            //     height: 1.4,
            //   ),
            // ),

          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// import 'dart:io';

// class AnalysingScreen extends StatelessWidget {
//   final String diseaseResult; // Add this field

//   AnalysingScreen({required this.diseaseResult}); // Update the constructor

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/1.gif', // Use the correct asset path
//               width: 450,
//               height: 450,
//               fit: BoxFit.cover,
//             ),
//             Text(
//               'We are analyzing your ECG. Keep waiting to get your Heart Condition...',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black.withOpacity(0.88),
//                 fontSize: 19,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w700,
//                 height: 1.4, // Adjust this value for line spacing
//               ),
//             ),
//             Text(
//               'Diagnosis Result: $diseaseResult', // Display the disease result
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black.withOpacity(0.88),
//                 fontSize: 19,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w700,
//                 height: 1.4, // Adjust this value for line spacing
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
