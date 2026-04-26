import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';

class ResultPage extends StatefulWidget {
  final AnalysisResult? result;
  final VoidCallback onNewAnalysis;

  const ResultPage({
    super.key,
    required this.result,
    required this.onNewAnalysis,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _saved = false;

  // ── Disease metadata ─────────────────────────────────────────────────────────
  static Map<String, Map<String, dynamic>> get _diseaseData => {
        'Anthracnose': {
          'color': const Color(0xFFE64A19),
          'icon': Icons.warning_amber_rounded,
          'emoji': '⚠️',
          'advice': '''⚠️ Anthracnose détectée — Champignon Colletotrichum

• Retirez et brûlez les feuilles infectées immédiatement
• Appliquez un fongicide à base de cuivre
• Évitez l'arrosage par aspersion (mouiller les feuilles)
• Améliorez la ventilation entre les branches
• Traitez en période sèche pour une meilleure efficacité''',
        },
        'Ash weevil': {
          'color': const Color(0xFF5D4037),
          'icon': Icons.pest_control,
          'emoji': '🐛',
          'advice': '''🐛 Charançon des agrumes détecté

• Inspectez le tronc et les branches pour des traces de galeries
• Appliquez un insecticide systémique homologué
• Posez des pièges collants autour de l'arbre
• Retirez les écorces endommagées
• Consultez un agronome si l'infestation est sévère''',
        },
        'Canker': {
          'color': const Color(0xFFFF8F00),
          'icon': Icons.warning_rounded,
          'emoji': '⚠️',
          'advice': '''⚠️ Chancre bactérien détecté — Xanthomonas citri

• ATTENTION : maladie très contagieuse !
• Éliminez toutes les parties infectées (feuilles, branches, fruits)
• Désinfectez vos outils avec de l'alcool à 70 % après chaque coupe
• Appliquez un bactéricide à base de cuivre
• Évitez de travailler sur l'arbre par temps humide
• Signalez le cas aux autorités phytosanitaires locales''',
        },
        'Greening': {
          'color': const Color(0xFFF9A825),
          'icon': Icons.warning_rounded,
          'emoji': '⚠️',
          'advice': '''⚠️ Huanglongbing (Greening) détecté — Candidatus Liberibacter

• MALADIE GRAVE ET INCURABLE — Agissez rapidement
• Isolez l'arbre malade pour éviter la propagation
• Contrôlez le psylle asiatique (Diaphorina citri) vecteur de la maladie
• Envisagez l'arrachage si l'arbre est fortement infecté
• Consultez impérativement un expert phytosanitaire
• Ne déplacez pas le matériel végétal infecté''',
        },
        'Healthy': {
          'color': const Color(0xFF2E7D32),
          'icon': Icons.check_circle_rounded,
          'emoji': '✅',
          'advice': '''✅ Votre arbre est en bonne santé ! Continuez vos bonnes pratiques :

• Arrosage régulier sans excès
• Taille annuelle pour favoriser l'aération
• Surveillance régulière des nouvelles feuilles
• Fertilisation équilibrée au printemps''',
        },
        'Leaf miner': {
          'color': const Color(0xFF6A1B9A),
          'icon': Icons.pest_control_rodent,
          'emoji': '🐛',
          'advice': '''🐛 Mineuse des feuilles détectée — Phyllocnistis citrella

• Retirez et détruisez les feuilles très touchées
• Appliquez un insecticide systémique (imidaclopride)
• Traitez les jeunes pousses qui sont les plus vulnérables
• Évitez les fertilisations azotées excessives (stimulent les pousses)
• Favorisez les auxiliaires naturels (parasitoïdes)''',
        },
      };

  Map<String, dynamic> _getInfo(String name) {
    // Case-insensitive lookup
    for (final entry in _diseaseData.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return {
      'color': const Color(0xFF607D8B),
      'icon': Icons.help_outline_rounded,
      'emoji': '❓',
      'advice': 'Aucune information disponible pour cette maladie.',
    };
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 80) return const Color(0xFF2E7D32);
    if (confidence >= 50) return const Color(0xFFFF8F00);
    return const Color(0xFFC62828);
  }

  Future<void> _saveToHistory() async {
    if (widget.result == null || _saved) return;
    try {
      await HistoryService.saveResult(widget.result!);
      setState(() => _saved = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Sauvegardé dans l\'historique'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) {
      return _buildEmptyState();
    }

    final result = widget.result!;
    final info = _getInfo(result.diseaseName);
    final color = info['color'] as Color;
    final icon = info['icon'] as IconData;
    final advice = info['advice'] as String;
    final conf = result.confidence;
    final confColor = _confidenceColor(conf);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          'Résultat de l\'analyse',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            _buildImageCard(result),
            const SizedBox(height: 16),

            // Disease badge
            _buildDiseaseBadge(result.diseaseName, color, icon),
            const SizedBox(height: 16),

            // Confidence card
            _buildConfidenceCard(conf, confColor),
            const SizedBox(height: 16),

            // Advice card
            _buildAdviceCard(advice, color),
            const SizedBox(height: 24),

            // Action buttons
            _buildSaveButton(),
            const SizedBox(height: 12),
            _buildNewAnalysisButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          'Résultat',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat disponible',
              style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Analysez une feuille pour voir les résultats ici',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onNewAnalysis,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Nouvelle analyse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(AnalysisResult result) {
    final imageFile = File(result.imagePath);
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imageFile.existsSync()
            ? Image.file(imageFile, fit: BoxFit.cover, width: double.infinity)
            : Container(
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Image non disponible', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDiseaseBadge(String name, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maladie détectée',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(double conf, Color confColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score de confiance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${conf.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: confColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: conf / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(confColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                conf >= 80
                    ? '🟢 Confiance élevée'
                    : conf >= 50
                        ? '🟠 Confiance modérée'
                        : '🔴 Confiance faible',
                style: TextStyle(fontSize: 12, color: confColor, fontWeight: FontWeight.w600),
              ),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(String advice, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment_outlined, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '📋 Conseils & Consignes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.grey[100]),
          const SizedBox(height: 14),
          Text(
            advice,
            style: const TextStyle(fontSize: 13.5, height: 1.7, color: Color(0xFF37474F)),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _saved ? null : _saveToHistory,
        icon: Icon(_saved ? Icons.check_rounded : Icons.save_rounded, size: 20),
        label: Text(
          _saved ? 'Sauvegardé ✓' : 'Sauvegarder dans l\'historique',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFA5D6A7),
          disabledForegroundColor: Colors.white,
          elevation: _saved ? 0 : 4,
          shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildNewAnalysisButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() => _saved = false);
          widget.onNewAnalysis();
        },
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: const Text(
          'Nouvelle analyse',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2E7D32),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
