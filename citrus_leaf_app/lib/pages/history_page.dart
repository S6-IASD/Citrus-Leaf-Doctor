import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<AnalysisResult> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final results = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _history = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int index) async {
    await HistoryService.deleteResult(index);
    await _loadHistory();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tout effacer', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Êtes-vous sûr de vouloir supprimer tout l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.clearAll();
      await _loadHistory();
    }
  }

  Color _diseaseColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('anthracnose')) return const Color(0xFFE64A19);
    if (lower.contains('ash') || lower.contains('weevil')) return const Color(0xFF5D4037);
    if (lower.contains('canker')) return const Color(0xFFFF8F00);
    if (lower.contains('greening')) return const Color(0xFFF9A825);
    if (lower.contains('healthy')) return const Color(0xFF2E7D32);
    if (lower.contains('leaf') || lower.contains('miner')) return const Color(0xFF6A1B9A);
    return const Color(0xFF607D8B);
  }

  IconData _diseaseIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('healthy')) return Icons.check_circle_rounded;
    if (lower.contains('ash') || lower.contains('weevil') || lower.contains('miner')) {
      return Icons.pest_control;
    }
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          'Historique',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70, size: 20),
                label: const Text(
                  'Tout effacer',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFA5D6A7).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_rounded, size: 50, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune analyse enregistrée',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos analyses apparaîtront ici\naprès les avoir sauvegardées',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: const Color(0xFF2E7D32),
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return _HistoryCard(
            result: item,
            diseaseColor: _diseaseColor(item.diseaseName),
            diseaseIcon: _diseaseIcon(item.diseaseName),
            onDelete: () => _deleteItem(index),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final Color diseaseColor;
  final IconData diseaseIcon;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.result,
    required this.diseaseColor,
    required this.diseaseIcon,
    required this.onDelete,
  });

  Color _confidenceColor(double c) {
    if (c >= 80) return const Color(0xFF2E7D32);
    if (c >= 50) return const Color(0xFFFF8F00);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = File(result.imagePath);
    final confColor = _confidenceColor(result.confidence);

    return Dismissible(
      key: Key('${result.imagePath}_${result.analyzedAt.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: SizedBox(
                width: 90,
                height: 90,
                child: imageFile.existsSync()
                    ? Image.file(imageFile, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(Icons.image_not_supported_rounded,
                            size: 32, color: Colors.grey[400]),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Disease badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: diseaseColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: diseaseColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(diseaseIcon, size: 12, color: diseaseColor),
                              const SizedBox(width: 4),
                              Text(
                                result.diseaseName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: diseaseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Confidence
                    Row(
                      children: [
                        Text(
                          '${result.confidence.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: confColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: result.confidence / 100,
                              minHeight: 5,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(confColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy à HH:mm').format(result.analyzedAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300], size: 22),
                onPressed: onDelete,
                tooltip: 'Supprimer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
