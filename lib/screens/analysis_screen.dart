import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/theme/app_theme.dart';
import '../viewmodels/analysis_viewmodel.dart';

class AnalysisScreen extends StatefulWidget {
  final String keyword;

  const AnalysisScreen({this.keyword = '', super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final int _diagramCount = 3;

  @override
  void initState() {
    super.initState();
    // Start at a large index divisible by 3 for infinite swiping both ways
    _pageController = PageController(initialPage: 999);
    _currentIndex = 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index % _diagramCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.chartLine, color: AppTheme.primaryNeon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Research Insights & Analytics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Visualizing ecosystem growth trends, keywords, and author impact',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Content Body
              Expanded(
                child: Consumer<AnalysisViewModel>(
                  builder: (context, model, child) {
                    if (model.keyword.isEmpty && !model.isLoading && model.errorMessage == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.chartArea,
                              size: 64,
                              color: AppTheme.borderNeon,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Please perform a search in the Search tab to view trends analysis.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    if (model.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryNeon,
                        ),
                      );
                    }

                    if (model.errorMessage != null) {
                      return Center(
                        child: Text(
                          model.errorMessage!,
                          style: const TextStyle(color: AppTheme.accentRose),
                        ),
                      );
                    }

                    if (model.trendData.isEmpty) {
                      return const Center(
                        child: Text(
                          'No trend data found for this topic.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    return _buildCarouselContent(context, model);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselContent(BuildContext context, AnalysisViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Topic Keyword tag centered
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Keyword: ${model.keyword}',
              style: const TextStyle(
                color: AppTheme.primaryNeon,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Carousel Slider wrapper
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Swipable PageView
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final pageIndex = index % _diagramCount;
                  if (pageIndex == 0) {
                    return _buildPublicationTrendSlide(context, model.trendData, model.keyword);
                  } else if (pageIndex == 1) {
                    return _buildTopKeywordsSlide(context, model.topKeywords, model.keyword);
                  } else {
                    return _buildAuthorImpactSlide(context, model.topAuthors, model.keyword);
                  }
                },
              ),

              // Left navigation arrow button
              Positioned(
                left: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.darkCardBackground.withValues(alpha: 0.8),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryNeon, size: 24),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),

              // Right navigation arrow button
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.darkCardBackground.withValues(alpha: 0.8),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryNeon, size: 24),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Dots Indicator Row
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_diagramCount, (index) {
            final isActive = _currentIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: isActive ? 16.0 : 8.0,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryNeon : AppTheme.borderNeon,
                borderRadius: BorderRadius.circular(4.0),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // --- Slide 1: Publication Trend (Line Chart) ---
  Widget _buildPublicationTrendSlide(BuildContext context, Map<int, int> trendData, String keyword) {
    // Sort years to plot line chart chronologically
    final sortedYears = trendData.keys.toList()..sort();
    final filteredYears = sortedYears.where((year) => year > 1950 && year <= DateTime.now().year).toList();

    final List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < filteredYears.length; i++) {
      final year = filteredYears[i];
      final count = trendData[year]!.toDouble();
      spots.add(FlSpot(i.toDouble(), count));
      if (count < minY) minY = count;
      if (count > maxY) maxY = count;
    }

    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 100;

    int peakYear = filteredYears.isNotEmpty ? filteredYears.first : 0;
    int maxCount = -1;
    trendData.forEach((year, count) {
      if (year > 1950 && year <= DateTime.now().year && count > maxCount) {
        maxCount = count;
        peakYear = year;
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagram metadata header
          _buildDiagramHeader(title: 'Ecosystem Flux', topic: 'Multi-dimensional analysis of research velocity'),
          const SizedBox(height: 16),

          // Peak Year Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.glassBox(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryNeon.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(FontAwesomeIcons.fire, color: AppTheme.secondaryNeon, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Peak Research Year',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$peakYear ($maxCount publications)',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Chart Box
          Container(
            height: 230,
            padding: const EdgeInsets.fromLTRB(5, 20, 15, 5),
            decoration: AppTheme.glassBox(
              color: AppTheme.darkCardBackground.withValues(alpha: 0.3),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < filteredYears.length) {
                          if (idx == 0 || idx == filteredYears.length - 1 || idx == (filteredYears.length / 2).floor()) {
                            return Text(
                              filteredYears[idx].toString(),
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: filteredYears.isNotEmpty ? (filteredYears.length - 1).toDouble() : 0,
                minY: minY * 0.9,
                maxY: maxY * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryNeon.withValues(alpha: 0.15),
                          AppTheme.secondaryNeon.withValues(alpha: 0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Slide 2: Top Keywords / Topics (Bar Chart) ---
  Widget _buildTopKeywordsSlide(BuildContext context, List<Map<String, dynamic>> topKeywords, String keyword) {
    // Filter display names
    final validTopics = topKeywords.where((k) {
      final name = k['key_display_name']?.toString() ?? '';
      return name.isNotEmpty && name.toLowerCase() != 'unknown';
    }).take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiagramHeader(title: 'Topical Footprint', topic: 'Semantics mapping and keyword dominance'),
          const SizedBox(height: 16),

          if (validTopics.isEmpty)
            const SizedBox(
              height: 250,
              child: Center(
                child: Text('No topic keyword analytics available.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else ...[
            // Bar Chart representation using custom bars
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassBox(),
              child: Column(
                children: List.generate(validTopics.length, (idx) {
                  final topicItem = validTopics[idx];
                  final name = topicItem['key_display_name']?.toString() ?? 'Unknown';
                  final count = topicItem['count'] as int? ?? 0;
                  
                  // Calculate max count for percentage width
                  final maxCount = validTopics.first['count'] as int? ?? 1;
                  final percentage = count / maxCount;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$count papers',
                              style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.borderNeon.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Slide 3: Author Impact (Bar Chart or List) ---
  Widget _buildAuthorImpactSlide(BuildContext context, List<Map<String, dynamic>> topAuthors, String keyword) {
    final validAuthors = topAuthors.where((a) {
      final name = a['key_display_name']?.toString() ?? '';
      return _isValidAuthorName(name);
    }).take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiagramHeader(title: 'Scholarly Velocity', topic: 'Top contributing researchers ranking'),
          const SizedBox(height: 16),

          if (validAuthors.isEmpty)
            const SizedBox(
              height: 250,
              child: Center(
                child: Text('No author impact analytics available.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassBox(),
              child: Column(
                children: List.generate(validAuthors.length, (idx) {
                  final authorItem = validAuthors[idx];
                  final name = authorItem['key_display_name']?.toString() ?? 'Unknown';
                  final count = authorItem['count'] as int? ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryNeon,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (idx + 1).toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count works',
                            style: const TextStyle(
                              color: AppTheme.secondaryNeon,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagramHeader({required String title, required String topic}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          topic,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  bool _isValidAuthorName(String name) {
    if (name.isEmpty) return false;
    final lower = name.toLowerCase();
    if (lower == 'unknown' ||
        lower.contains('anonymous') ||
        lower.contains('exam') ||
        lower.contains('collaboration') ||
        lower.contains('association') ||
        lower.contains('group')) {
      return false;
    }
    return true;
  }
}
