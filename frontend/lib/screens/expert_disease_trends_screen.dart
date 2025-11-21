import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/auth_service.dart';
import 'package:crop_disease_app/services/disease_analysis_api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpertDiseaseTrendsScreen extends StatefulWidget {
  const ExpertDiseaseTrendsScreen({super.key});

  @override
  State<ExpertDiseaseTrendsScreen> createState() => _ExpertDiseaseTrendsScreenState();
}

class _ExpertDiseaseTrendsScreenState extends State<ExpertDiseaseTrendsScreen> {
  Map<String, dynamic> _trendsData = {};
  Map<String, dynamic> _predictionsData = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedTimeRange = 'Last 30 Days';
  String _selectedRegion = 'All Regions';

  final List<String> _timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
  ];

  final List<String> _regions = [
    'All Regions',
    'North India',
    'South India',
    'East India',
    'West India',
    'Central India',
  ];

  @override
  void initState() {
    super.initState();
    _loadTrendsData();
  }

  Future<void> _loadTrendsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final results = await Future.wait([
        DiseaseAnalysisApiService.getDiseaseTrends(token),
        DiseaseAnalysisApiService.getDiseaseOutbreakPredictions(token),
      ]);

      setState(() {
        _trendsData = results[0];
        _predictionsData = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load trends: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Trends'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrendsData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadTrendsData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(),
                    const SizedBox(height: 20),
                    _buildOutbreakRiskCard(),
                    const SizedBox(height: 20),
                    _buildTrendsChart(),
                    const SizedBox(height: 20),
                    _buildPredictionsSection(),
                    const SizedBox(height: 20),
                    _buildRecommendationsSection(),
                    const SizedBox(height: 20),
                    _buildWeatherImpactSection(),
                    const SizedBox(height: 20),
                    _buildSeasonalForecastSection(),
                  ],
                ),
              ),
            ),
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
          ElevatedButton(
            onPressed: _loadTrendsData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time Range:'),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedTimeRange,
                        isExpanded: true,
                        items: _timeRanges.map((range) {
                          return DropdownMenuItem(value: range, child: Text(range));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTimeRange = value!;
                          });
                          _loadTrendsData();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Region:'),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedRegion,
                        isExpanded: true,
                        items: _regions.map((region) {
                          return DropdownMenuItem(value: region, child: Text(region));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value!;
                          });
                          _loadTrendsData();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutbreakRiskCard() {
    final outbreakRisk = _predictionsData['outbreakRisk'] as Map<String, dynamic>? ?? {};
    final riskLevel = outbreakRisk['level'] as String? ?? 'Low';
    final confidence = (outbreakRisk['confidence'] as double? ?? 0.0) * 100;
    final timeframe = outbreakRisk['timeframe'] as String? ?? 'Unknown';

    Color riskColor;
    IconData riskIcon;

    switch (riskLevel.toLowerCase()) {
      case 'high':
        riskColor = Colors.red;
        riskIcon = Icons.warning;
        break;
      case 'medium':
        riskColor = Colors.orange;
        riskIcon = Icons.info;
        break;
      case 'low':
        riskColor = Colors.green;
        riskIcon = Icons.check_circle;
        break;
      default:
        riskColor = Colors.grey;
        riskIcon = Icons.help;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(riskIcon, color: riskColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Outbreak Risk Assessment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        riskLevel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confidence',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${confidence.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timeframe',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeframe,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart() {
    final trends = _trendsData['trends'] as List<dynamic>? ?? [];

    if (trends.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.trending_up, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No trend data available',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease Trends Over Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: _createTrendLines(trends),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendLegend(trends),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _createTrendLines(List<dynamic> trends) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return trends.asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;
      final color = colors[index % colors.length];

      // Mock data points for visualization
      final spots = List.generate(6, (i) {
        final baseValue = (trend['percentage'] as double? ?? 0.0).abs();
        final variation = (i - 2.5) * 2; // Create some variation
        return FlSpot(i.toDouble(), baseValue + variation);
      });

      return LineChartBarData(
        spots: spots,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: color.withOpacity(0.1),
        ),
      );
    }).toList();
  }

  Widget _buildTrendLegend(List<dynamic> trends) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        final color = colors[index % colors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              trend['disease'] ?? 'Unknown',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPredictionsSection() {
    final predictions = _predictionsData['predictions'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease Outbreak Predictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (predictions.isEmpty)
              const Center(child: Text('No predictions available'))
            else
              ...predictions.map((prediction) => _buildPredictionItem(prediction)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(Map<String, dynamic> prediction) {
    final disease = prediction['disease'] ?? 'Unknown';
    final probability = (prediction['probability'] as double? ?? 0.0) * 100;
    final regions = (prediction['regions'] as List<dynamic>? ?? []).join(', ');
    final timeframe = prediction['timeframe'] ?? 'Unknown';

    Color probabilityColor;
    if (probability >= 70) {
      probabilityColor = Colors.red;
    } else if (probability >= 40) {
      probabilityColor = Colors.orange;
    } else {
      probabilityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    disease,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: probabilityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: probabilityColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${probability.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: probabilityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    regions,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  timeframe,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _trendsData['recommendations'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expert Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recommendations.isEmpty)
              const Center(child: Text('No recommendations available'))
            else
              ...recommendations.map((rec) => _buildRecommendationItem(rec)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(recommendation, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherImpactSection() {
    final weatherImpact = _trendsData['weatherImpact'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Impact Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (weatherImpact.isEmpty)
              const Center(child: Text('No weather data available'))
            else
              ...weatherImpact.entries.map((entry) => _buildWeatherItem(entry.key, entry.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherItem(String factor, String impact) {
    IconData icon;
    Color color;

    switch (factor.toLowerCase()) {
      case 'humidity':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'temperature':
        icon = Icons.thermostat;
        color = Colors.red;
        break;
      case 'rainfall':
        icon = Icons.cloud;
        color = Colors.grey;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  impact,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalForecastSection() {
    final seasonalForecast = _trendsData['seasonalForecast'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seasonal Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (seasonalForecast.isEmpty)
              const Center(child: Text('No forecast data available'))
            else
              ...seasonalForecast.entries.map((entry) => _buildForecastItem(entry.key, entry.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(String period, String forecast) {
    IconData icon;
    Color color;

    switch (period.toLowerCase()) {
      case 'nextmonth':
        icon = Icons.calendar_month;
        color = Colors.blue;
        break;
      case 'nextseason':
        icon = Icons.calendar_view_month;
        color = Colors.green;
        break;
      case 'risklevel':
        icon = Icons.warning;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  forecast,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
