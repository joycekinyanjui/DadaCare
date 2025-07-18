import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ReferPatientScreen extends StatefulWidget {
  final String doctorHospital;
  final String doctorName;

  const ReferPatientScreen({
    super.key,
    required this.doctorHospital,
    required this.doctorName,
  });

  @override
  State<ReferPatientScreen> createState() => _ReferPatientScreenState();
}

class _ReferPatientScreenState extends State<ReferPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _database = FirebaseDatabase.instance.ref().child('referrals');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String? selectedHospital;
  File? selectedFile;
  bool isUploading = false;

  final hospitals = [
    "Pumwani Maternity Hospital",
    "Kakamega County Referral Hospital",
    "Machakos Level 5 Hospital",
    "Embu Level 5 Hospital",
    "Mombasa County Hospital",
  ];

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> uploadFileToFirebase(File file) async {
    try {
      final filename = path.basename(file.path);
      final ref = FirebaseStorage.instance.ref().child('lab_results/$filename');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  Future<void> submitReferral() async {
    if (_formKey.currentState?.validate() != true || selectedHospital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields.")),
      );
      return;
    }

    setState(() => isUploading = true);

    String? fileUrl;
    if (selectedFile != null) {
      fileUrl = await uploadFileToFirebase(selectedFile!);
    }

    final referralData = {
      'name': nameController.text,
      'age': ageController.text,
      'sex': sexController.text,
      'condition': conditionController.text,
      'notes': notesController.text,
      'from': widget.doctorHospital,
      'doctorName': widget.doctorName,
      'to': selectedHospital,
      'labResultUrl': fileUrl ?? '',
      'timestamp': ServerValue.timestamp,
    };

    await _database.push().set(referralData);

    setState(() {
      isUploading = false;
      nameController.clear();
      ageController.clear();
      sexController.clear();
      conditionController.clear();
      notesController.clear();
      selectedHospital = null;
      selectedFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient referred successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Refer a Patient"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Full Name", nameController),
              _buildTextField("Age", ageController),
              _buildTextField("Sex", sexController),
              _buildTextField("Condition", conditionController),
              _buildTextField("Referral Notes", notesController, maxLines: 3),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedHospital,
                decoration: const InputDecoration(
                  labelText: "Refer To Hospital",
                ),
                items:
                    hospitals.map((hospital) {
                      return DropdownMenuItem(
                        value: hospital,
                        child: Text(hospital),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => selectedHospital = val),
                validator: (val) => val == null ? "Select hospital" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  selectedFile != null ? "Change File" : "Attach Lab Results",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
              ),
              if (selectedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("Attached: ${path.basename(selectedFile!.path)}"),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isUploading ? null : submitReferral,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue.shade800,
                ),
                child:
                    isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Referral"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
