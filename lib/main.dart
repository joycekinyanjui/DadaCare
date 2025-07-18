import 'package:dadacare/helpers/inventory_loader.dart';
import 'package:dadacare/pages/TherapistRegistrationForm.dart';
import 'package:dadacare/pages/TherapistReplyPage%20.dart';
import 'package:dadacare/pages/agent_page.dart';
import 'package:dadacare/pages/therapist_page.dart';
import 'package:dadacare/screens/book_appoinments_screen.dart';
import 'package:dadacare/screens/cervical_predict_screen.dart';
import 'package:dadacare/screens/doctor_appointments_screen.dart';
import 'package:dadacare/screens/doctor_home.dart';
import 'package:dadacare/screens/doctor_login_screen.dart';
import 'package:dadacare/screens/e_registry_screen.dart';
import 'package:dadacare/screens/home_screen.dart';
import 'package:dadacare/screens/inventory_screen.dart';
import 'package:dadacare/screens/login_screen.dart';
import 'package:dadacare/screens/nearby_hospitals_screen.dart';
import 'package:dadacare/screens/pricing_screen.dart';
import 'package:dadacare/screens/referral_form_screen.dart';
import 'package:dadacare/screens/referred_patient_screen.dart';
import 'package:dadacare/screens/research_papers_screen.dart';
import 'package:dadacare/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await InventoryLoader.loadExcelIfNeeded();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/price': (context) => const PricingPage(),
        '/risk': (context) => CervicalPredictScreen(),
        '/chat': (context) => const AgentPage(),
        '/doctor_login': (context) => DoctorLoginScreen(),
        '/doctor_home': (context) => DoctorHomeScreen(),
        '/inventory': (context) => InventoryScreen(),
        '/research': (context) => ResearchPapersScreen(),
        '/therapist_register': (context) => const TherapistRegistrationForm(),
        '/refer':
            (context) =>
                const ReferPatientScreen(doctorName: '', doctorHospital: ''),
        '/view_referrals': (context) => const ReferredPatientsScreen(),
        '/book': (context) => BookAppointmentScreen(),
        '/appointments': (context) => DoctorAppointmentsScreen(),
        '/erigistry': (context) => ERegistryScreen(),
      },
      onGenerateRoute: (settings) {
        final user = FirebaseAuth.instance.currentUser;

        // ══════ THERAPIST-PATIENT CHAT PAGE (from user side) ══════
        if (settings.name == '/therapist') {
          if (user == null) return _errorRoute("User not logged in");

          final userId = user.uid;

          return MaterialPageRoute(
            builder:
                (context) => FutureBuilder<DataSnapshot>(
                  future: FirebaseDatabase.instance.ref('therapists').get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data?.value == null) {
                      return const Scaffold(
                        body: Center(
                          child: Text("No therapist available yet."),
                        ),
                      );
                    }

                    final allTherapists = Map<String, dynamic>.from(
                      snapshot.data!.value as Map,
                    );
                    final firstTherapistId = allTherapists.keys.first;

                    return TherapistPage(
                      userId: userId,
                      therapistId: firstTherapistId,
                    );
                  },
                ),
          );
        }

        // ══════ VOLUNTEER THERAPIST PORTAL (doctor replying to patients) ══════
        if (settings.name == '/volunteer') {
          if (user == null) return _errorRoute("User not logged in");

          final userId = FirebaseAuth.instance.currentUser!.uid;

          return MaterialPageRoute(
            builder:
                (context) => FutureBuilder<DataSnapshot>(
                  future:
                      FirebaseDatabase.instance.ref('therapists/$userId').get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data?.value == null) {
                      return const TherapistRegistrationForm();
                    }

                    // ✅ Doctor is registered, show full list of patients in the page itself
                    return TherapistReplyPage(
                      therapistId: userId,
                      userId: "", // We'll ignore this field now
                    );
                  },
                ),
          );
        }

        return null; // fallback to unknown route
      },
    );
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text(message)),
          ),
    );
  }
}

class Landing extends StatefulWidget {
  const Landing({super.key});
  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  void initState() {
    super.initState();
    decideNext();
  }

  Future<void> decideNext() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("doctor_hospital") == null) {
      Navigator.pushReplacementNamed(context, "/select_hospital");
    } else {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
