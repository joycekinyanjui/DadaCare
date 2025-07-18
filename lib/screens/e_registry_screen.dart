import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ERegistryScreen extends StatefulWidget {
  const ERegistryScreen({super.key});

  @override
  State<ERegistryScreen> createState() => _ERegistryScreenState();
}

class _ERegistryScreenState extends State<ERegistryScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'e_registry',
  );

  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String papSmearStatus = 'Negative';
  String hpvStatus = 'Negative';
  String hivStatus = 'Negative';

  final List<String> options = ['Negative', 'Positive', 'Unknown'];

  @override
  void dispose() {
    _regionController.dispose();
    _ageController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final uuid = const Uuid().v4();

      final data = {
        "uuid": uuid,
        "region": _regionController.text,
        "age": int.parse(_ageController.text),
        "date": _dateController.text,
        "pap_smear_status": papSmearStatus,
        "hpv_status": hpvStatus,
        "hiv_status": hivStatus,
        "notes": _notesController.text,
        "timestamp": ServerValue.timestamp,
      };

      _dbRef.push().set(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Record saved successfully")),
      );

      _formKey.currentState!.reset();
      _regionController.clear();
      _ageController.clear();
      _dateController.clear();
      _notesController.clear();
    }
  }

  Future<void> _downloadCSV() async {
    final snapshot = await _dbRef.get();

    if (!snapshot.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No data found.")));
      return;
    }

    List<List<dynamic>> rows = [
      [
        "UUID",
        "Region",
        "Age",
        "Date",
        "Pap Smear",
        "HPV",
        "HIV",
        "Notes",
        "Timestamp",
      ],
    ];

    Map data = snapshot.value as Map;
    data.forEach((key, value) {
      rows.add([
        value['uuid'],
        value['region'],
        value['age'],
        value['date'],
        value['pap_smear_status'],
        value['hpv_status'],
        value['hiv_status'],
        value['notes'],
        value['timestamp'],
      ]);
    });

    String csv = const ListToCsvConverter().convert(rows);

    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final path = "${directory!.path}/e_registry_data.csv";
      final file = File(path);
      await file.writeAsString(csv);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("CSV downloaded to: $path")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text("e-Registry"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadCSV),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_regionController, "Region"),
              _buildTextField(_ageController, "Age", isNumber: true),
              _buildDateField(),
              _buildDropdown("Pap Smear Result", papSmearStatus, (val) {
                setState(() => papSmearStatus = val!);
              }),
              _buildDropdown("HPV Status", hpvStatus, (val) {
                setState(() => hpvStatus = val!);
              }),
              _buildDropdown("HIV Status", hivStatus, (val) {
                setState(() => hivStatus = val!);
              }),
              _buildTextField(_notesController, "Notes", maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Save Entry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: "Date of Screening",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: _pickDate,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Select screening date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String current,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: current,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
        items:
            options
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
