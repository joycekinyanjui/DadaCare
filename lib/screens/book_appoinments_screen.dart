import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  String _reason = '';
  DateTime? _selectedDate;
  String? _selectedHospital;
  String _paymentMethod = 'Mpesa';

  final List<String> _hospitals = [
    "Pumwani Maternity Hospital",
    "Kakamega County Referral Hospital",
    "Machakos Level 5 Hospital",
    "Embu Level 5 Hospital",
    "Mombasa County Hospital",
  ];

  final List<String> _paymentMethods = ['Mpesa', 'Credit Card', 'Cash', 'SHA'];

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedHospital != null) {
      final user = _auth.currentUser;
      _formKey.currentState!.save();

      final appointmentRef = _database.child('appointments').push();
      await appointmentRef.set({
        'patientId': user!.uid,
        'reason': _reason,
        'date': _selectedDate.toString(),
        'hospitalId': _selectedHospital,
        'paymentMethod': _paymentMethod,
        'status': 'pending',
        'timestamp': ServerValue.timestamp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully!')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please complete all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Reason for appointment',
                  filled: true,
                  fillColor: Colors.lightBlue.shade50,
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _reason = val ?? '',
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'This field is required'
                            : null,
              ),
              SizedBox(height: 16),
              ListTile(
                tileColor: Colors.lightBlue.shade50,
                title: Text(
                  _selectedDate == null
                      ? 'Choose Date'
                      : 'Selected: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedHospital,
                hint: Text('Select Hospital'),
                items:
                    _hospitals.map((hospital) {
                      return DropdownMenuItem(
                        value: hospital,
                        child: Text(hospital),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedHospital = val),
                decoration: InputDecoration(
                  labelText: 'Hospital',
                  filled: true,
                  fillColor: Colors.lightBlue.shade50,
                  border: OutlineInputBorder(),
                ),
                validator:
                    (val) => val == null ? 'Please select a hospital' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items:
                    _paymentMethods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _paymentMethod = val!),
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  filled: true,
                  fillColor: Colors.lightBlue.shade50,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Confirm Appointment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
