import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  _DoctorAppointmentsScreenState createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final _database = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _fetchAppointments() {
    _database.child('appointments').onValue.listen((event) {
      final data = event.snapshot.value;
      final List<Map<dynamic, dynamic>> loadedAppointments = [];

      if (data != null && data is Map<dynamic, dynamic>) {
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            loadedAppointments.add({
              'id': key,
              'patientId': value['patientId'],
              'reason': value['reason'],
              'date': value['date'],
              'hospitalId': value['hospitalId'],
              'status': value['status'],
              'paymentMethod': value['paymentMethod'],
            });
          }
        });
      }

      setState(() {
        _appointments = loadedAppointments.reversed.toList();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Appointments"),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _appointments.isEmpty
              ? Center(child: Text("No appointments found"))
              : ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (ctx, index) {
                  final appointment = _appointments[index];
                  return Card(
                    color: Colors.lightBlue.shade50,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text("Reason: ${appointment['reason']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${appointment['date'] ?? 'N/A'}"),
                          Text("Hospital: ${appointment['hospitalId']}"),
                          Text("Status: ${appointment['status']}"),
                          Text("Payment: ${appointment['paymentMethod']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
