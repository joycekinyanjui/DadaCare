import 'package:dadacare/screens/home_screen.dart';
import 'package:dadacare/screens/login_screen.dart';
import 'package:dadacare/screens/nearby_hospitals_screen.dart';
import 'package:dadacare/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const WelcomeScreen(),
      initialRoute: '/',
      routes: {
        '/home_screen': (context) => const HomeScreen(),
        '/hospitals': (context) => NearbyHospitalsScreen(),
        '/login': (context) => const LoginScreen(),
        // '/map': (context) => const MapScreen(),
        // '/prices': (context) => const PriceScreen(),
        // '/anonymous': (context) => const AnonymousModeScreen(),
      },
    );
  }
}
