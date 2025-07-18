import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  String? doctorHospital;
  bool isLoading = true;

  final String therapistId = FirebaseAuth.instance.currentUser!.uid;

  final List<String> hospitals = [
    "Pumwani Maternity Hospital",
    "Kakamega County Referral Hospital",
    "Machakos Level 5 Hospital",
    "Embu Level 5 Hospital",
    "Mombasa County Hospital",
  ];

  @override
  void initState() {
    super.initState();
    loadHospital();
  }

  Future<void> loadHospital() async {
    final prefs = await SharedPreferences.getInstance();
    final hospital = prefs.getString("doctor_hospital");
    setState(() {
      doctorHospital = hospital;
      isLoading = false;
    });
  }

  Future<void> saveHospital(String hospital) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("doctor_hospital", hospital);
    setState(() {
      doctorHospital = hospital;
    });
  }

  void showHospitalSelectionDialog() {
    String? selectedHospital;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select Hospital"),
            content: SingleChildScrollView(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Hospital",
                  border: OutlineInputBorder(),
                ),
                value: doctorHospital,
                items:
                    hospitals
                        .map(
                          (h) => DropdownMenuItem(
                            value: h,
                            child: Text(h, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  selectedHospital = value;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedHospital != null) {
                    saveHospital(selectedHospital!);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 213, 221),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 122, 205, 243),
        title: const Text("DadaCare Home"),
        actions: [
          Image.asset("assets/Medical research-pana.png"),
          IconButton(
            icon: const Icon(Icons.home_work),
            tooltip: "Change Hospital",
            onPressed: showHospitalSelectionDialog,
          ),
        ],
      ),
      body:
          doctorHospital == null
              ? Center(
                child: ElevatedButton(
                  onPressed: showHospitalSelectionDialog,
                  child: const Text("Select your hospital"),
                ),
              )
              : GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                children: [
                  _homeCard("Appointments", Icons.calendar_today, () {
                    Navigator.of(context).pushNamed('/appointments');
                  }),
                  _homeCard("Research Papers", Icons.article, () {
                    Navigator.pushNamed(context, '/research');
                  }),
                  _homeCard(
                    "Volunteer As a Consultant",
                    Icons.volunteer_activism,
                    () async {
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final snapshot =
                          await FirebaseDatabase.instance
                              .ref()
                              .child('therapists/$uid')
                              .get();

                      if (!snapshot.exists) {
                        Navigator.pushNamed(context, '/therapist_register');
                      } else {
                        Navigator.pushNamed(context, '/volunteer');
                      }
                    },
                  ),

                  _homeCard("E-Registry", Icons.chat, () {
                    Navigator.of(context).pushNamed('/erigistry');
                  }),
                  _homeCard("Inventory", Icons.medical_services, () {
                    Navigator.pushNamed(context, '/inventory');
                  }),
                  _homeCard("Refer Patients", Icons.person_add_alt_1, () {
                    Navigator.of(context).pushNamed('/refer');
                  }),
                  _homeCard(
                    "See Referred Patients",
                    Icons.assignment_outlined,
                    () {
                      Navigator.of(context).pushNamed('/view_referrals');
                    },
                  ),
                  _homeCard("AI Reccomendation", Icons.earbuds, () {
                    Navigator.of(context).pushNamed('/risk');
                  }),
                ],
              ),
    );
  }

  Widget _homeCard(String label, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.lightBlue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
