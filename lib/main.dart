import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heart_app/UserHistory.dart';
import 'package:heart_app/analysing_ecg.dart';
import 'package:heart_app/diet_screen.dart';
import 'package:heart_app/dietreults_screen.dart';
import 'package:heart_app/doctorsui.dart';
import 'package:heart_app/ecg_screen.dart';
import 'package:heart_app/heartsurvey_screen.dart';
import 'package:heart_app/map_window2.dart';
import 'package:heart_app/models/user.dart';
import 'package:heart_app/myrecords_screen.dart';
import 'package:heart_app/patientsui.dart';
import 'package:heart_app/pharmacies_screen.dart';
import 'package:heart_app/profile.dart';
import 'package:heart_app/registerdoctorui.dart';
import 'package:heart_app/resultsheart_screen.dart';
import 'package:heart_app/userswitchui.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:heart_app/app_routes.dart';
import 'package:heart_app/loginui.dart';
import 'package:heart_app/registerui.dart';
import 'package:heart_app/diagnosisui.dart';
import 'package:heart_app/homeui.dart';
import 'package:heart_app/verifydiagnosis.dart';
import 'package:heart_app/analysing.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp();
  }
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCcTCP0G1XxBIZsKr5TJPMLU9RLoisEius",
          appId: "1:871830581613:web:2bd0f7b245bbbe1a68ea64",
          messagingSenderId: "871830581613",
          projectId: "ecg-diagnosis-system"));
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => RegUser(userName: "")),
    ],
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<RegUser>();
    return MaterialApp(
      title: 'ECG Based Diagnosis System',
      initialRoute: user.userName.isNotEmpty && user.userName!="" ? AppRoutes.home : AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.userSelect: (context) => SwitchScreen(),
        AppRoutes.home: (context) => homeScreen(),
        AppRoutes.registration: (context) => RegistrationScreen(),
        AppRoutes.registrationDoctor: (context) => RegistrationDoctorScreen(),
        AppRoutes.doctors: (context) => DoctorsScreen(),
        AppRoutes.patients: (context) => PatientsScreen(),
        AppRoutes.heartsurvey: (context) => HeartSurveyScreen(),
        AppRoutes.ecg: (context) => ECGScreen(),
        AppRoutes.mapharmacy: (context) => Map2Screen(initialLocation: LatLng(6.9271, 79.8812), name: ''),
        AppRoutes.pharmacies: (context) => PharmaciesScreen(),
        AppRoutes.dietPlan: (context) => DietScreen(),
        AppRoutes.dietResult: (context) => DietResultsScreen(predictedResult: ''),
        AppRoutes.myHistory: (context) => MYHistoryScreen(userEmail: ''),
        AppRoutes.userHistory: (context) => UserHistoryScreen(username: ''),
        AppRoutes.resultheart: (context) => ResultsHeartScreen(cardioPred: '', probability: 0),
        AppRoutes.myProfile: (context) => UserProfileScreen(email: ''),
        AppRoutes.diagnosis: (context) =>
            DiagnosisScreen(),
        AppRoutes.verification: (context) =>
            VerificationScreen(diseaseResult: AppRoutes.analyzing,),
        AppRoutes.analyzing: (context) =>
            AnalysingScreen(cardioPred: '', probability: 0),
        AppRoutes.analyzingECG: (context) =>
            AnalysingECGScreen(ecgPred: '', probability: 0),
      },
    );
  }
}

