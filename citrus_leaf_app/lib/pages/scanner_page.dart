import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classifier.dart';
import '../models/analysis_result.dart';

class ScannerPage extends StatefulWidget {
  final Classifier classifier;
  final void Function(AnalysisResult result) onResultReady;

  const ScannerPage({
    super.key,
    required this.classifier,
    required this.onResultReady,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorType;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _errorType = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Impossible d\'accéder à ${source == ImageSource.camera ? "la caméra" : "la galerie"} : $e');
      }
    }
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorType = null;
    });

    try {
      final result = await widget.classifier.classify(_selectedImage!);
      final analysisResult = AnalysisResult(
        imagePath: _selectedImage!.path,
        diseaseName: result.key,
        confidence: result.value,
        analyzedAt: DateTime.now(),
      );

      if (mounted) {
        setState(() => _isAnalyzing = false);
        widget.onResultReady(analysisResult);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        if (e.toString().contains('NotCitrusLeaf')) {
          setState(() => _errorType = 'not_leaf');
        } else if (e.toString().contains('DiseaseNotRecognized')) {
          setState(() => _errorType = 'unknown_disease');
        } else {
          _showError('Erreur lors de l\'analyse : $e');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          'Analyser une feuille',
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
            const SizedBox(height: 8),
            // Image area
            _buildImageArea(),
            const SizedBox(height: 24),

            if (_errorType != null)
              _buildErrorCard()
            else ...[
              // Source buttons
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Prendre une photo',
                      color: const Color(0xFF1565C0),
                      onTap: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Depuis la galerie',
                      color: const Color(0xFF6A1B9A),
                      onTap: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Analyze button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (_selectedImage != null && !_isAnalyzing) ? _analyze : null,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search_rounded, size: 22),
                  label: Text(
                    _isAnalyzing ? 'Analyse en cours...' : 'Lancer l\'analyse',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    elevation: _selectedImage != null ? 4 : 0,
                    shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Tips
            if (_selectedImage == null && _errorType == null) _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    bool isNotLeaf = _errorType == 'not_leaf';
    
    IconData icon = isNotLeaf ? Icons.hide_image_rounded : Icons.find_in_page_rounded;
    // IconData icon = isNotLeaf ? Icons.nature_off_rounded : Icons.find_in_page_rounded;
    String title = isNotLeaf ? 'Aucune feuille détectée' : 'Maladie non reconnue';
    String subtitle = isNotLeaf 
        ? 'Assurez-vous que la feuille de citrus est bien visible et bien éclairée au centre de l\'image.' 
        : 'La maladie n\'a pas pu être identifiée avec certitude. La feuille est peut-être atteinte d\'une infection non répertoriée.';
    Color primaryColor = isNotLeaf ? const Color(0xFFE64A19) : const Color(0xFF5D4037);
    Color bgColor = Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt_rounded, color: primaryColor, size: 18),
                  label: Text('Photo', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library_rounded, color: primaryColor, size: 18),
                  label: Text('Galerie', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedImage != null
              ? (_errorType == 'not_leaf' ? const Color(0xFFE64A19) : 
                 _errorType == 'unknown_disease' ? const Color(0xFF5D4037) : 
                 const Color(0xFF2E7D32))
              : const Color(0xFFA5D6A7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_selectedImage!, fit: BoxFit.cover),
                  if (_errorType != null)
                    Container(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  // Overlay gradient
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: _isAnalyzing ? null : () => setState(() {
                          _selectedImage = null;
                          _errorType = null;
                        }),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA5D6A7).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 44,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune image sélectionnée',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prenez une photo ou choisissez\nune image dans votre galerie',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.4),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 8),
              Text(
                'Conseils pour une meilleure analyse',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _tip('Photographiez une seule feuille à la fois'),
          _tip('Assurez-vous d\'un bon éclairage naturel'),
          _tip('La feuille doit occuper la majorité de l\'image'),
          _tip('Évitez les reflets et les zones floues'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap != null ? color.withValues(alpha: 0.1) : Colors.grey[100],
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: onTap != null ? color.withValues(alpha: 0.4) : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: onTap != null ? color : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: onTap != null ? color : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
