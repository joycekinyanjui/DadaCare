import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/kitenge.jpg',
              fit: BoxFit.cover,
              color: Colors.black38,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "DadaCare",
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Tuzuie Saratani",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    child: const Text("Get Started"),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/anonymous');
                    },
                    child: const Text("Use Anonymous Mode"),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/doctor_login');
                      // You can implement Swahili toggle here
                    },
                    child: const Text(
                      "Login as a doctor",
                      style: TextStyle(
                        color: Color.fromARGB(179, 14, 142, 216),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
