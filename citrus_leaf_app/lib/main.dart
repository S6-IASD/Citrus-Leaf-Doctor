import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/scanner_page.dart';
import 'pages/result_page.dart';
import 'pages/history_page.dart';
import 'services/classifier.dart';
import 'models/analysis_result.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CitrusLeafApp());
}

class CitrusLeafApp extends StatelessWidget {
  const CitrusLeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citrus Leaf Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFFA5D6A7),
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF1F8E9),
        ),
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2E7D32),
          unselectedItemColor: Color(0xFF90A4AE),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 12,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final Classifier _classifier = Classifier();
  bool _modelLoaded = false;
  String? _modelError;
  AnalysisResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _initClassifier();
  }

  Future<void> _initClassifier() async {
    try {
      await _classifier.loadModel();
      if (mounted) setState(() => _modelLoaded = true);
    } catch (e) {
      if (mounted) setState(() => _modelError = e.toString());
    }
  }

  void _goToScanner() => setState(() => _currentIndex = 1);

  void _onResultReady(AnalysisResult result) {
    setState(() {
      _lastResult = result;
      _currentIndex = 2;
    });
  }

  void _onNewAnalysis() {
    setState(() {
      _lastResult = null;
      _currentIndex = 1;
    });
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while model is loading
    if (!_modelLoaded && _modelError == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF2E7D32),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Citrus Leaf Doctor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              const SizedBox(height: 16),
              const Text(
                'Chargement du modèle IA...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Show error if model failed to load
    if (_modelError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F8E9),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 72, color: Colors.red[400]),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de chargement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _modelError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _modelError = null);
                    _initClassifier();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pages = [
      HomePage(onAnalyzePressed: _goToScanner),
      ScannerPage(classifier: _classifier, onResultReady: _onResultReady),
      ResultPage(result: _lastResult, onNewAnalysis: _onNewAnalysis),
      const HistoryPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt_rounded),
              label: 'Analyser',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'Résultat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'Historique',
            ),
          ],
        ),
      ),
    );
  }
}
