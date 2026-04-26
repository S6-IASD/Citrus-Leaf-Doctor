import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:math' as math;

class Classifier {
  static const String _modelPath = 'assets/models/mobilenetv3.tflite';
  static const String _validationModelPath = 'assets/models/validation.tflite';
  static const String _labelsPath = 'assets/labels.txt';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  Interpreter? _validationInterpreter;
  List<String> _labels = [];

  bool get isLoaded => _interpreter != null && _validationInterpreter != null && _labels.isNotEmpty;

  Future<void> loadModel() async {
    try {
      // Load labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Load models
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _validationInterpreter = await Interpreter.fromAsset(_validationModelPath);
    } catch (e) {
      throw Exception('Erreur lors du chargement des modèles : $e');
    }
  }

  Future<MapEntry<String, double>> classify(File imageFile) async {
    if (_interpreter == null || _validationInterpreter == null) {
      throw Exception('Les modèles ne sont pas chargés.');
    }

    try {
      // Decode image
      final bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('Impossible de décoder l\'image.');
      }

      // Resize to 224x224
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.linear,
      );

      // Normalize pixel values to [0.0, 1.0] and build input tensor
      // Shape: [1, 224, 224, 3]
      var inputTensor = List.generate(
        1,
        (_) => List.generate(
          _inputSize,
          (y) => List.generate(
            _inputSize,
            (x) {
              final pixel = resizedImage.getPixel(x, y);
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            },
          ),
        ),
      );

      // 1. Validation Model (Citrus Leaf or Not)
      // Output tensor: [1, 1]
      var valOutputTensor = List.generate(1, (_) => List.filled(1, 0.0));
      _validationInterpreter!.run(inputTensor, valOutputTensor);
      
      double score = valOutputTensor[0][0];
      double probNotCitrus = 1.0 / (1.0 + math.exp(-score));
      double probCitrus = 1.0 - probNotCitrus;
      
      if (probCitrus <= 0.5) {
        throw Exception('NotCitrusLeaf');
      }

      // 2. Disease Classification Model
      // Output tensor: [1, 6]
      var outputTensor = List.generate(1, (_) => List.filled(_labels.length, 0.0));
      _interpreter!.run(inputTensor, outputTensor);

      final List<double> scores = List<double>.from(outputTensor[0]);

      // Appliquer Softmax pour convertir les sorties brutes en probabilités
      double maxLogit = scores.reduce((curr, next) => curr > next ? curr : next);
      double sumExp = 0.0;
      
      for (int i = 0; i < scores.length; i++) {
        scores[i] = math.exp(scores[i] - maxLogit);
        sumExp += scores[i];
      }

      // Trouver la classe avec la probabilité maximale
      int maxIndex = 0;
      double maxProbability = 0.0;
      for (int i = 0; i < scores.length; i++) {
        double prob = scores[i] / sumExp;
        if (prob > maxProbability) {
          maxProbability = prob;
          maxIndex = i;
        }
      }

      // Vérifier le seuil de 60%
      double confidence = maxProbability * 100.0;
      if (confidence <= 60.0) {
        throw Exception('DiseaseNotRecognized');
      }

      final label = maxIndex < _labels.length ? _labels[maxIndex] : 'Inconnu';
      return MapEntry(label, confidence);
    } catch (e) {
      if (e.toString().contains('NotCitrusLeaf') || e.toString().contains('DiseaseNotRecognized')) {
        rethrow;
      }
      throw Exception('Erreur lors de l\'analyse : $e');
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _validationInterpreter?.close();
    _validationInterpreter = null;
  }
}
