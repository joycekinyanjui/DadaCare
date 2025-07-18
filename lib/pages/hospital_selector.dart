import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HospitalSelectorScreen extends StatelessWidget {
  final List<String> hospitals = [
    "Pumwani Maternity Hospital",
    "Kakamega County Referral Hospital",
    "Machakos Level 5 Hospital",
    "Embu Level 5 Hospital",
    "Mombasa County Hospital",
  ];

  HospitalSelectorScreen({super.key});

  Future<void> saveHospital(String hospital) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("doctor_hospital", hospital);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text("Select Hospital"),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(hospitals[index]),
              onTap: () async {
                await saveHospital(hospitals[index]);
                Navigator.pushReplacementNamed(context, "/home");
              },
            ),
          );
        },
      ),
    );
  }
}
