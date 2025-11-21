import 'package:flutter/material.dart';

class ExpertKnowledgeBaseScreen extends StatefulWidget {
  const ExpertKnowledgeBaseScreen({super.key});

  @override
  State<ExpertKnowledgeBaseScreen> createState() =>
      _ExpertKnowledgeBaseScreenState();
}

class _ExpertKnowledgeBaseScreenState extends State<ExpertKnowledgeBaseScreen> {
  List<Map<String, dynamic>> _diseases = [];
  List<Map<String, dynamic>> _filteredDiseases = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Fungal',
    'Bacterial',
    'Viral',
    'Insect Damage',
    'Nutritional',
    'Environmental',
  ];

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiseases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Mock data for now - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _diseases = _getMockDiseases();
        _filteredDiseases = _diseases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load diseases: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getMockDiseases() {
    return [
      {
        'id': 1,
        'name': 'Tomato Late Blight',
        'scientificName': 'Phytophthora infestans',
        'category': 'Fungal',
        'severity': 'High',
        'description':
            'A devastating fungal disease that affects tomatoes and potatoes, causing rapid plant death.',
        'symptoms': [
          'Dark, water-soaked lesions on leaves',
          'White mold growth on underside of leaves',
          'Brown spots on stems and fruits',
          'Rapid wilting and plant death',
        ],
        'causes': [
          'High humidity (>90%)',
          'Cool temperatures (15-20°C)',
          'Poor air circulation',
          'Overhead watering',
        ],
        'prevention': [
          'Plant resistant varieties',
          'Ensure proper spacing for air circulation',
          'Avoid overhead watering',
          'Apply preventive fungicides',
          'Remove infected plant debris',
        ],
        'treatment': [
          'Apply copper-based fungicides',
          'Use systemic fungicides like metalaxyl',
          'Remove and destroy infected plants',
          'Improve drainage and air circulation',
          'Apply fungicides every 7-10 days during wet periods',
        ],
        'affectedCrops': ['Tomato', 'Potato'],
        'imageUrl': '/images/tomato_late_blight.jpg',
        'riskLevel': 'Critical',
        'lastUpdated': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
      },
      {
        'id': 2,
        'name': 'Wheat Rust',
        'scientificName': 'Puccinia spp.',
        'category': 'Fungal',
        'severity': 'High',
        'description':
            'A fungal disease that causes significant yield losses in wheat crops worldwide.',
        'symptoms': [
          'Orange or rust-colored pustules on leaves',
          'Yellow halos around lesions',
          'Premature leaf death',
          'Reduced grain size and quality',
        ],
        'causes': [
          'High humidity and moisture',
          'Moderate temperatures (15-25°C)',
          'Dense crop planting',
          'Susceptible varieties',
        ],
        'prevention': [
          'Plant rust-resistant varieties',
          'Practice crop rotation',
          'Avoid excessive nitrogen fertilization',
          'Ensure proper field drainage',
          'Monitor weather conditions',
        ],
        'treatment': [
          'Apply fungicides at first sign of infection',
          'Use systemic fungicides like tebuconazole',
          'Apply protective fungicides preventively',
          'Remove volunteer wheat plants',
          'Time fungicide applications with growth stages',
        ],
        'affectedCrops': ['Wheat', 'Barley', 'Oats'],
        'imageUrl': '/images/wheat_rust.jpg',
        'riskLevel': 'High',
        'lastUpdated': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
      {
        'id': 3,
        'name': 'Rice Blast',
        'scientificName': 'Magnaporthe oryzae',
        'category': 'Fungal',
        'severity': 'Critical',
        'description':
            'One of the most destructive diseases of rice, causing severe yield losses.',
        'symptoms': [
          'Diamond-shaped lesions on leaves',
          'Gray centers with brown borders',
          'Node infection causing stem breakage',
          'Panicle infection causing grain loss',
        ],
        'causes': [
          'High humidity (>90%)',
          'Cool temperatures (20-25°C)',
          'Excessive nitrogen fertilization',
          'Poor field drainage',
        ],
        'prevention': [
          'Plant resistant varieties',
          'Avoid excessive nitrogen application',
          'Ensure proper field drainage',
          'Practice crop rotation',
          'Monitor weather conditions',
        ],
        'treatment': [
          'Apply fungicides at boot stage',
          'Use systemic fungicides like tricyclazole',
          'Apply protective fungicides preventively',
          'Improve field drainage',
          'Reduce nitrogen fertilization',
        ],
        'affectedCrops': ['Rice'],
        'imageUrl': '/images/rice_blast.jpg',
        'riskLevel': 'Critical',
        'lastUpdated': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      {
        'id': 4,
        'name': 'Corn Leaf Spot',
        'scientificName': 'Helminthosporium maydis',
        'category': 'Fungal',
        'severity': 'Medium',
        'description':
            'A common fungal disease affecting corn leaves, reducing photosynthetic capacity.',
        'symptoms': [
          'Small, circular brown spots on leaves',
          'Yellow halos around lesions',
          'Lesion enlargement and coalescence',
          'Premature leaf death',
        ],
        'causes': [
          'High humidity and leaf wetness',
          'Warm temperatures (25-30°C)',
          'Poor air circulation',
          'Susceptible varieties',
        ],
        'prevention': [
          'Plant resistant hybrids',
          'Ensure proper plant spacing',
          'Practice crop rotation',
          'Remove crop residues',
          'Avoid excessive irrigation',
        ],
        'treatment': [
          'Apply fungicides at tasseling stage',
          'Use protective fungicides like chlorothalonil',
          'Apply systemic fungicides if needed',
          'Improve field drainage',
          'Monitor disease progression',
        ],
        'affectedCrops': ['Corn', 'Maize'],
        'imageUrl': '/images/corn_leaf_spot.jpg',
        'riskLevel': 'Medium',
        'lastUpdated': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
      },
      {
        'id': 5,
        'name': 'Potato Early Blight',
        'scientificName': 'Alternaria solani',
        'category': 'Fungal',
        'severity': 'Medium',
        'description':
            'A fungal disease that affects potato leaves, stems, and tubers.',
        'symptoms': [
          'Dark brown lesions with concentric rings',
          'Yellow halos around lesions',
          'Premature defoliation',
          'Tuber infection causing dark spots',
        ],
        'causes': [
          'High humidity and leaf wetness',
          'Warm temperatures (20-30°C)',
          'Plant stress conditions',
          'Susceptible varieties',
        ],
        'prevention': [
          'Plant certified seed potatoes',
          'Practice crop rotation',
          'Ensure proper plant spacing',
          'Avoid overhead irrigation',
          'Remove infected plant debris',
        ],
        'treatment': [
          'Apply fungicides preventively',
          'Use protective fungicides like mancozeb',
          'Apply systemic fungicides if needed',
          'Improve air circulation',
          'Monitor weather conditions',
        ],
        'affectedCrops': ['Potato', 'Tomato'],
        'imageUrl': '/images/potato_early_blight.jpg',
        'riskLevel': 'Medium',
        'lastUpdated': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': 6,
        'name': 'Cotton Bollworm',
        'scientificName': 'Helicoverpa armigera',
        'category': 'Insect Damage',
        'severity': 'High',
        'description':
            'A major pest that attacks cotton bolls, causing significant yield losses.',
        'symptoms': [
          'Holes in cotton bolls',
          'Frass (insect excrement) on bolls',
          'Premature boll opening',
          'Reduced fiber quality',
        ],
        'causes': [
          'High pest populations',
          'Favorable weather conditions',
          'Lack of natural enemies',
          'Susceptible varieties',
        ],
        'prevention': [
          'Plant Bt cotton varieties',
          'Practice crop rotation',
          'Use pheromone traps',
          'Encourage natural enemies',
          'Monitor pest populations',
        ],
        'treatment': [
          'Apply insecticides when threshold is reached',
          'Use selective insecticides',
          'Apply Bt formulations',
          'Use integrated pest management',
          'Time applications with pest life cycle',
        ],
        'affectedCrops': ['Cotton', 'Tomato', 'Chickpea'],
        'imageUrl': '/images/cotton_bollworm.jpg',
        'riskLevel': 'High',
        'lastUpdated': DateTime.now()
            .subtract(const Duration(days: 4))
            .toIso8601String(),
      },
    ];
  }

  void _filterDiseases() {
    setState(() {
      _filteredDiseases = _diseases.where((disease) {
        final matchesCategory =
            _selectedCategory == 'All' ||
            disease['category'] == _selectedCategory;
        final matchesSearch =
            _searchQuery.isEmpty ||
            disease['name'].toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            disease['scientificName'].toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            disease['affectedCrops'].any(
              (crop) => crop.toLowerCase().contains(_searchQuery.toLowerCase()),
            );

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiseases,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search diseases, crops, or symptoms...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _filterDiseases();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterDiseases();
                });
              },
            ),
          ),

          // Category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Category: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _filterDiseases();
                              });
                            },
                            selectedColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).primaryColor,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      'Total Diseases',
                      _diseases.length.toString(),
                      Colors.blue,
                    ),
                    _buildStatColumn(
                      'Filtered',
                      _filteredDiseases.length.toString(),
                      Colors.green,
                    ),
                    _buildStatColumn(
                      'Critical',
                      _diseases
                          .where((d) => d['riskLevel'] == 'Critical')
                          .length
                          .toString(),
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _filteredDiseases.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadDiseases,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredDiseases.length,
                      itemBuilder: (context, index) {
                        final disease = _filteredDiseases[index];
                        return _buildDiseaseCard(disease);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadDiseases, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No diseases found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search criteria or filters',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> disease) {
    final riskLevel = disease['riskLevel'] as String;
    final severity = disease['severity'] as String;
    final affectedCrops = disease['affectedCrops'] as List<String>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDiseaseDetails(disease),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      disease['name'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRiskChip(riskLevel),
                ],
              ),
              const SizedBox(height: 8),

              // Scientific Name
              Text(
                disease['scientificName'],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),

              // Category and Severity
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    disease['category'],
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.warning, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(severity, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 8),

              // Affected Crops
              Row(
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Affects: ${affectedCrops.join(', ')}',
                      style: TextStyle(color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description Preview
              Text(
                disease['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Bottom Row
              Row(
                children: [
                  Text(
                    'Updated ${_formatDate(disease['lastUpdated'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showDiseaseDetails(disease),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskChip(String riskLevel) {
    Color color;
    IconData icon;

    switch (riskLevel.toLowerCase()) {
      case 'critical':
        color = Colors.red.shade900;
        icon = Icons.warning;
        break;
      case 'high':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.info;
        break;
      case 'low':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            riskLevel.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showDiseaseDetails(Map<String, dynamic> disease) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiseaseDetailsBottomSheet(disease: disease),
    );
  }
}

class _DiseaseDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> disease;

  const _DiseaseDetailsBottomSheet({required this.disease});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Disease Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Scientific Name
                  Text(
                    disease['name'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disease['scientificName'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Basic Info
                  _buildInfoSection('Basic Information', [
                    _buildInfoRow(
                      'Category',
                      disease['category'],
                      Icons.category,
                    ),
                    _buildInfoRow(
                      'Severity',
                      disease['severity'],
                      Icons.warning,
                    ),
                    _buildInfoRow(
                      'Risk Level',
                      disease['riskLevel'],
                      Icons.priority_high,
                    ),
                    _buildInfoRow(
                      'Affected Crops',
                      (disease['affectedCrops'] as List<String>).join(', '),
                      Icons.agriculture,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Description
                  _buildTextSection('Description', disease['description']),

                  const SizedBox(height: 24),

                  // Symptoms
                  _buildListSection(
                    'Symptoms',
                    disease['symptoms'],
                    Icons.visibility,
                  ),

                  const SizedBox(height: 24),

                  // Causes
                  _buildListSection('Causes', disease['causes'], Icons.info),

                  const SizedBox(height: 24),

                  // Prevention
                  _buildListSection(
                    'Prevention',
                    disease['prevention'],
                    Icons.shield,
                  ),

                  const SizedBox(height: 24),

                  // Treatment
                  _buildListSection(
                    'Treatment',
                    disease['treatment'],
                    Icons.medical_services,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(content, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
