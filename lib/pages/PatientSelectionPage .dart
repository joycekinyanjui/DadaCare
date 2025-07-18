import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientSelectionPage extends StatefulWidget {
  final String therapistId;

  const PatientSelectionPage({super.key, required this.therapistId});

  @override
  State<PatientSelectionPage> createState() => _PatientSelectionPageState();
}

class _PatientSelectionPageState extends State<PatientSelectionPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<String> patientIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientsFromChats();
  }

  Future<void> _loadPatientsFromChats() async {
    final snapshot = await _database.child('therapist_chats').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final Set<String> foundPatients = {};

      print("Therapist ID: ${widget.therapistId}");
      print("Raw therapist_chats data: ${snapshot.value}");

      data.forEach((chatId, chatData) {
        if (chatData is Map) {
          final participants = Map<String, dynamic>.from(
            chatData['participants'] ?? {},
          );
          print("Chat [$chatId] participants: $participants");

          if (participants[widget.therapistId] == true) {
            participants.forEach((id, isParticipant) {
              if (id.toString() != widget.therapistId &&
                  isParticipant == true) {
                foundPatients.add(id.toString());
              }
            });
          }
        }
      });

      setState(() {
        patientIds = foundPatients.toList();
        isLoading = false;
      });
    } else {
      print("No therapist_chats found at all.");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Patient"),
        backgroundColor: Colors.lightBlue,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : patientIds.isEmpty
              ? const Center(child: Text("No patients have chatted yet."))
              : ListView.builder(
                itemCount: patientIds.length,
                itemBuilder: (context, index) {
                  final patientId = patientIds[index];
                  return ListTile(
                    title: Text("Patient ID: $patientId"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/volunteer',
                        arguments: {
                          'therapistId': widget.therapistId,
                          'userId': patientId,
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
