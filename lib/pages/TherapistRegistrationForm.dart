import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TherapistRegistrationForm extends StatefulWidget {
  const TherapistRegistrationForm({super.key});

  @override
  State<TherapistRegistrationForm> createState() =>
      _TherapistRegistrationFormState();
}

class _TherapistRegistrationFormState extends State<TherapistRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hospitalController = TextEditingController();
  bool _agreed = false;
  bool _loading = false;

  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || !_agreed) return;

    setState(() => _loading = true);

    final uid = _auth.currentUser!.uid;
    await _db.child('therapists/$uid').set({
      'name': _nameController.text.trim(),
      'hospital': _hospitalController.text.trim(),
      'agreedToTerms': true,
    });

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/doctor_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Therapist Registration")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                        ),
                        validator:
                            (value) => value!.isEmpty ? "Name required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _hospitalController,
                        decoration: const InputDecoration(
                          labelText: "Hospital",
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? "Hospital required" : null,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text(
                          "I agree to the terms and conditions.",
                        ),
                        value: _agreed,
                        onChanged: (val) => setState(() => _agreed = val!),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
