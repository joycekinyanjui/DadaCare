import 'package:flutter/material.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
import 'dart:typed_data';

class RiskFormScreen extends StatefulWidget {
  const RiskFormScreen({super.key});

  @override
  State<RiskFormScreen> createState() => _RiskFormScreenState();
}

class _RiskFormScreenState extends State<RiskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final ageController = TextEditingController();
  final partnersController = TextEditingController();
  final firstSexController = TextEditingController();
  final pregnanciesController = TextEditingController();
  final smokesController = TextEditingController();
  final citologyController = TextEditingController();
  final dxhpvController = TextEditingController();

  Interpreter? interpreter;
  String result = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('cervical_model.tflite');
      debugPrint("✅ Model loaded successfully");
      setState(() {
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint("❌ Error loading model: $e");
      debugPrint(stack.toString());
      setState(() {
        isLoading = false;
        result = "Failed to load model: $e";
      });
    }
  }

  Future<void> predict() async {
    try {
      if (interpreter == null) {
        setState(() {
          result = "Model not ready yet.";
        });
        return;
      }

      if (!_formKey.currentState!.validate()) return;

      final inputs = [
        double.parse(ageController.text),
        double.parse(partnersController.text),
        double.parse(firstSexController.text),
        double.parse(pregnanciesController.text),
        double.parse(smokesController.text),
        double.parse(citologyController.text),
        double.parse(dxhpvController.text),
      ];

      final inputBuffer = Float32List.fromList(inputs).reshape([1, 7]);
      final outputBuffer = List.filled(1 * 1, 0.0).reshape([1, 1]);

      interpreter!.run(inputBuffer, outputBuffer);

      final prob = outputBuffer[0][0];
      setState(() {
        result = "Biopsy risk: ${(prob * 100).toStringAsFixed(2)}%";
      });
    } catch (e, stack) {
      debugPrint("❌ Error during prediction: $e");
      debugPrint(stack.toString());
      setState(() {
        result = "Prediction failed: $e";
      });
    }
  }

  @override
  void dispose() {
    ageController.dispose();
    partnersController.dispose();
    firstSexController.dispose();
    pregnanciesController.dispose();
    smokesController.dispose();
    citologyController.dispose();
    dxhpvController.dispose();
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biopsy Risk Predictor")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildField(ageController, "Age", "Enter age"),
                      _buildField(
                        partnersController,
                        "Number of sexual partners",
                        "e.g. 2",
                      ),
                      _buildField(
                        firstSexController,
                        "First sexual intercourse (age)",
                        "e.g. 16",
                      ),
                      _buildField(
                        pregnanciesController,
                        "Number of pregnancies",
                        "e.g. 1",
                      ),
                      _buildField(
                        smokesController,
                        "Smokes (0=No, 1=Yes)",
                        "0 or 1",
                      ),
                      _buildField(
                        citologyController,
                        "Pap Smear Result (0=Neg, 1=Pos)",
                        "0 or 1",
                      ),
                      _buildField(
                        dxhpvController,
                        "HPV Test (0=Neg, 1=Pos)",
                        "0 or 1",
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: predict,
                        child: const Text("Predict"),
                      ),
                      const SizedBox(height: 20),
                      if (result.isNotEmpty)
                        Text(
                          result,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required";
          }
          return null;
        },
      ),
    );
  }
}
