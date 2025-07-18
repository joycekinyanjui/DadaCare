import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class RiskModelService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('model/cervical_risk.tflite');
  }

  /// Age, sexual partners, pregnancies, etc
  /// Make sure to pass a list of 9 floats for example
  Future<double> predictRisk(List<double> inputData) async {
    if (_interpreter == null) throw Exception('Interpreter not loaded');

    // Create input tensor
    var input = TensorBuffer.createFixedSize([
      1,
      inputData.length,
    ], TfLiteType.float32);
    input.loadList(inputData, shape: []);

    // Create output tensor
    var output = TensorBuffer.createFixedSize([1, 1], TfLiteType.float32);

    _interpreter!.run(input.buffer, output.buffer);

    return output.getDoubleList()[0];
  }

  void close() {
    _interpreter?.close();
  }
}
