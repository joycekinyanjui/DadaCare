import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CervicalPredictScreen extends StatefulWidget {
  const CervicalPredictScreen({super.key});

  @override
  _CervicalPredictScreenState createState() => _CervicalPredictScreenState();
}

class _CervicalPredictScreenState extends State<CervicalPredictScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _recommendation;

  final _ageController = TextEditingController();
  final _partnersController = TextEditingController();
  final _firstSexAgeController = TextEditingController();

  String? _hpvResult,
      _papSmear,
      _smoking,
      _stds,
      _region,
      _insurance,
      _screening;

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _recommendation = null;
    });

    final url = Uri.parse('https://joycekinyanjui.pythonanywhere.com/predict');
    final body = {
      "Age": int.parse(_ageController.text),
      "Sexual Partners": int.parse(_partnersController.text),
      "First Sexual Activity Age": int.parse(_firstSexAgeController.text),
      "HPV Test Result": _hpvResult!,
      "Pap Smear Result": _papSmear!,
      "Smoking Status": _smoking!,
      "STDs History": _stds!,
      "Region": _region!,
      "Insrance Covered": _insurance!,
      "Screening Type Last": _screening!,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final json = jsonDecode(response.body);
      setState(() {
        _recommendation = json['predicted_action'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
    String hintSw,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintSw,
          style: TextStyle(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _inputDecoration(label),
          items:
              items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hintSw,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintSw,
          style: TextStyle(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(label),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Color(0xFF3B224C)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFE4D4EC)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text("Cervical Health Assistant"),
        backgroundColor: Color.fromARGB(255, 107, 151, 218),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      "Age",
                                      _ageController,
                                      "Weka umri wako",
                                    ),
                                    SizedBox(height: 12),
                                    _buildTextField(
                                      "Sexual Partners",
                                      _partnersController,
                                      "Ni wangapi umewahi kushiriki nao?",
                                    ),
                                    SizedBox(height: 12),
                                    _buildTextField(
                                      "First Sexual Activity Age",
                                      _firstSexAgeController,
                                      "Ulianza ngono ukiwa na umri gani?",
                                    ),
                                    SizedBox(height: 12),
                                    _buildDropdown(
                                      "HPV Test Result",
                                      ["Positive", "Negative"],
                                      _hpvResult,
                                      (val) => setState(() => _hpvResult = val),
                                      "Matokeo ya kipimo cha HPV",
                                    ),
                                    SizedBox(height: 12),
                                    _buildDropdown(
                                      "Pap Smear Result",
                                      ["Normal", "Abnormal"],
                                      _papSmear,
                                      (val) => setState(() => _papSmear = val),
                                      "Matokeo ya Pap Smear yako",
                                    ),
                                    SizedBox(height: 12),
                                    _buildDropdown(
                                      "Smoking Status",
                                      ["Smoker", "Non-Smoker"],
                                      _smoking,
                                      (val) => setState(() => _smoking = val),
                                      "Je, unavuta sigara?",
                                    ),
                                    SizedBox(height: 12),
                                    _buildDropdown(
                                      "STDs History",
                                      ["Yes", "No"],
                                      _stds,
                                      (val) => setState(() => _stds = val),
                                      "Je, umewahi kuwa na magonjwa ya zinaa?",
                                    ),
                                    SizedBox(height: 12),
                                    _buildDropdown(
                                      "Region",
                                      [
                                        "Nairobi",
                                        "Central",
                                        "Western",
                                        "Eastern",
                                        "Nyanza",
                                        "Rift Valley",
                                        "Coast",
                                        "North Eastern",
                                      ],
                                      _region,
                                      (val) => setState(() => _region = val),
                                      "Taja eneo unakoishi",
                                    ),
                                    SizedBox(height: 12),
                                    _buildDropdown(
                                      "Insurance Covered",
                                      ["Yes", "No"],
                                      _insurance,
                                      (val) => setState(() => _insurance = val),
                                      "Je, una bima ya afya?",
                                    ),
                                    SizedBox(height: 12),
                                    _buildDropdown(
                                      "Last Screening Type",
                                      ["VIA", "Pap smear", "HPV test"],
                                      _screening,
                                      (val) => setState(() => _screening = val),
                                      "Ulichunguzwa mara ya mwisho kwa njia gani?",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _predict,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  107,
                                  155,
                                  218,
                                ),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Get Recommendation",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_recommendation != null) ...[
                        SizedBox(height: 24),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Color(0xFFFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_florist,
                                  color: Color(0xFFDA6BA0),
                                  size: 40,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Recommended Action",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B224C),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _recommendation!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF3B224C),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/book');
                                    // Navigate to appointment screen
                                  },
                                  icon: Icon(Icons.calendar_month),
                                  label: Text("Book Appointment"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      107,
                                      142,
                                      218,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/price');
                                    // Navigate to prices screen
                                  },
                                  icon: Icon(
                                    Icons.monetization_on_outlined,
                                    color: Color.fromARGB(255, 107, 142, 218),
                                  ),
                                  label: Text(
                                    "See Prices",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 107, 155, 218),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Color.fromARGB(255, 107, 142, 218),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
      ),
    );
  }
}
