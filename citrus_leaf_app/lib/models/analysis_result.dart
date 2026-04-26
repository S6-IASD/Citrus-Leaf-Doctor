import 'dart:convert';

class AnalysisResult {
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final DateTime analyzedAt;

  AnalysisResult({
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        imagePath: json['imagePath'] as String,
        diseaseName: json['diseaseName'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory AnalysisResult.fromJsonString(String jsonString) =>
      AnalysisResult.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
