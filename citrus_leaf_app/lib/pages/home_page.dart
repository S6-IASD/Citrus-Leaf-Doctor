import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onAnalyzePressed;

  const HomePage({super.key, required this.onAnalyzePressed});

  static const List<Map<String, dynamic>> _diseases = [
    {
      'name': 'Anthracnose',
      'color': Color(0xFFE64A19),
      'icon': Icons.warning_amber_rounded,
      'description': 'Champignon Colletotrichum',
    },
    {
      'name': 'Ash Weevil',
      'color': Color(0xFF5D4037),
      'icon': Icons.pest_control,
      'description': 'Charançon des agrumes',
    },
    {
      'name': 'Canker',
      'color': Color(0xFFFF8F00),
      'icon': Icons.warning_rounded,
      'description': 'Xanthomonas citri',
    },
    {
      'name': 'Greening',
      'color': Color(0xFFF9A825),
      'icon': Icons.warning_rounded,
      'description': 'Candidatus Liberibacter',
    },
    {
      'name': 'Healthy',
      'color': Color(0xFF2E7D32),
      'icon': Icons.check_circle_rounded,
      'description': 'Feuille saine',
    },
    {
      'name': 'Leaf Miner',
      'color': Color(0xFF6A1B9A),
      'icon': Icons.pest_control_rodent,
      'description': 'Phyllocnistis citrella',
    },
  ];

  static const List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.camera_alt_rounded,
      'title': 'Photographiez',
      'desc': 'Prenez une photo de la feuille suspecte',
      'color': Color(0xFF1565C0),
    },
    {
      'icon': Icons.biotech_rounded,
      'title': 'Analyse IA',
      'desc': 'L\'IA analyse la feuille en quelques secondes',
      'color': Color(0xFF6A1B9A),
    },
    {
      'icon': Icons.check_circle_rounded,
      'title': 'Diagnostic',
      'desc': 'Recevez le diagnostic et les conseils adaptés',
      'color': Color(0xFF2E7D32),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.eco_rounded, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Citrus Leaf Doctor',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Détectez les maladies de vos agrumes en quelques secondes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analyze button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: onAnalyzePressed,
                      icon: const Icon(Icons.search_rounded, size: 22),
                      label: const Text(
                        'Analyser une feuille',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // How it works section
                  _sectionTitle('Comment ça marche'),
                  const SizedBox(height: 14),
                  Row(
                    children: _steps.map((step) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _StepCard(
                            icon: step['icon'] as IconData,
                            title: step['title'] as String,
                            desc: step['desc'] as String,
                            color: step['color'] as Color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Diseases section
                  _sectionTitle('Maladies détectables'),
                  const SizedBox(height: 14),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: _diseases.length,
                    itemBuilder: (context, index) {
                      final d = _diseases[index];
                      return _DiseaseCard(
                        name: d['name'] as String,
                        color: d['color'] as Color,
                        icon: d['icon'] as IconData,
                        description: d['description'] as String,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _StepCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 10, color: Colors.grey[600], height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final String description;

  const _DiseaseCard({
    required this.name,
    required this.color,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.85), color],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
