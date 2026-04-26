import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_result.dart';

class HistoryService {
  static const String _key = 'citrus_analysis_history';

  static Future<List<AnalysisResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((json) {
      try {
        return AnalysisResult.fromJsonString(json);
      } catch (_) {
        return null;
      }
    }).whereType<AnalysisResult>().toList();
  }

  static Future<void> saveResult(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];
    // Insert at top (most recent first)
    jsonList.insert(0, result.toJsonString());
    await prefs.setStringList(_key, jsonList);
  }

  static Future<void> deleteResult(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < jsonList.length) {
      jsonList.removeAt(index);
      await prefs.setStringList(_key, jsonList);
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
