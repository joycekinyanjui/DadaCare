import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferredPatientsScreen extends StatefulWidget {
  const ReferredPatientsScreen({super.key});

  @override
  State<ReferredPatientsScreen> createState() => _ReferredPatientsScreenState();
}

class _ReferredPatientsScreenState extends State<ReferredPatientsScreen> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child(
    'referrals',
  );
  List<Map<dynamic, dynamic>> referredPatients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  void _loadReferrals() async {
    final snapshot = await _ref.get();

    if (snapshot.exists) {
      final patients = <Map<dynamic, dynamic>>[];
      for (var entry in snapshot.children) {
        final data = entry.value as Map<dynamic, dynamic>;
        data['key'] = entry.key;
        patients.add(data);
      }

      setState(() {
        referredPatients = patients.reversed.toList(); // latest first
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _openFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open the file.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Referred Patients"),
        backgroundColor: Colors.blue.shade800,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : referredPatients.isEmpty
              ? const Center(child: Text("No referred patients yet."))
              : ListView.builder(
                itemCount: referredPatients.length,
                itemBuilder: (context, index) {
                  final patient = referredPatients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        patient['name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Referred To: ${patient['to'] ?? '-'}"),
                          Text("Doctor: ${patient['doctorName'] ?? '-'}"),
                          Text("Condition: ${patient['condition'] ?? '-'}"),
                          Text("Notes: ${patient['notes'] ?? '-'}"),
                          const SizedBox(height: 4),
                          if (patient['labResultUrl'] != null &&
                              patient['labResultUrl'].toString().isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text("View Lab Result"),
                              onPressed:
                                  () => _openFile(patient['labResultUrl']),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
    );
  }
}
