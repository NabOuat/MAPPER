import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Charger les statistiques au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatisticsProvider>(context, listen: false).loadStatistics();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Résumé'),
            Tab(text: 'Catégories'),
            Tab(text: 'Activité'),
          ],
        ),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, child) {
          if (statsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (statsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Erreur: ${statsProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  ElevatedButton(
                    onPressed: () => statsProvider.loadStatistics(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(statsProvider),
              _buildCategoriesTab(statsProvider),
              _buildActivityTab(statsProvider),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSummaryTab(StatisticsProvider statsProvider) {
    final summary = statsProvider.getStatsSummary();
    final totalDistance = summary['totalDistance'] as double;
    final placesAdded = summary['placesAdded'] as int;
    final placesVisited = summary['placesVisited'] as int;
    final activeDays = summary['activeDays'] as int;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé de vos activités',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          
          // Carte de statistiques
          _buildStatCard(
            icon: Icons.place,
            title: 'Lieux ajoutés',
            value: placesAdded.toString(),
            color: AppColors.accentCyan,
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          _buildStatCard(
            icon: Icons.visibility,
            title: 'Lieux visités',
            value: placesVisited.toString(),
            color: Colors.green,
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          _buildStatCard(
            icon: Icons.route,
            title: 'Distance parcourue',
            value: '${totalDistance.toStringAsFixed(1)} km',
            color: Colors.orange,
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          _buildStatCard(
            icon: Icons.calendar_today,
            title: 'Jours actifs',
            value: activeDays.toString(),
            color: Colors.purple,
          ),
          
          const SizedBox(height: AppDimensions.paddingXL),
          
          // Conseils
          const Text(
            'Conseils',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          
          _buildTipCard(
            icon: Icons.lightbulb,
            title: 'Explorez de nouveaux endroits',
            description: 'Essayez de visiter des lieux dans différentes catégories pour diversifier votre expérience.',
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          _buildTipCard(
            icon: Icons.share,
            title: 'Partagez vos découvertes',
            description: 'Ajoutez des lieux intéressants pour aider les autres utilisateurs à découvrir de nouveaux endroits.',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoriesTab(StatisticsProvider statsProvider) {
    final categoryData = statsProvider.getCategoryChartData();
    
    if (categoryData.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lieux par catégorie',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          
          // Graphique en barres
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: categoryData.isNotEmpty 
                    ? (categoryData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b) * 1.2).toDouble()
                    : 10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (touchedBarGroup) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${categoryData[groupIndex]['category']}: ${rod.toY.round()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < categoryData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              categoryData[value.toInt()]['category'].toString().substring(0, 3),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                barGroups: categoryData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final count = data['count'] as int;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: AppColors.accentCyan,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Légende
          Wrap(
            spacing: AppDimensions.paddingM,
            runSpacing: AppDimensions.paddingS,
            children: categoryData.map((data) {
              return Chip(
                label: Text(
                  '${data['category']}: ${data['count']}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.accentCyan,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityTab(StatisticsProvider statsProvider) {
    final activityData = statsProvider.getDailyActivityChartData();
    
    if (activityData.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activité quotidienne',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          const Text(
            'Nombre de lieux ajoutés par jour',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          
          // Graphique en ligne
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < activityData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              activityData[value.toInt()]['date'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                minX: 0,
                maxX: (activityData.length - 1).toDouble(),
                minY: 0,
                maxY: activityData.isNotEmpty
                    ? (activityData.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b) * 1.2).toDouble()
                    : 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: activityData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['count'] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppColors.accentCyan,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accentCyan.withAlpha(51),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.blueGrey,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index >= 0 && index < activityData.length) {
                          final data = activityData[index];
                          return LineTooltipItem(
                            '${data['date']}: ${touchedSpot.y.toInt()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Résumé
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résumé de l\'activité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  
                  // Total des lieux ajoutés sur la période
                  Row(
                    children: [
                      const Icon(Icons.place, color: AppColors.accentCyan),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'Total: ${activityData.map((e) => e['count'] as int).reduce((a, b) => a + b)} lieux',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingS),
                  
                  // Moyenne par jour
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'Moyenne: ${(activityData.map((e) => e['count'] as int).reduce((a, b) => a + b) / activityData.length).toStringAsFixed(1)} lieux/jour',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.amber,
              size: 24,
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
