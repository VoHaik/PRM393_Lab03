import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/analysis/analysis_bloc.dart';
import '../bloc/analysis/analysis_state.dart';

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
                child: BlocBuilder<AnalysisBloc, AnalysisState>(
                  builder: (context, state) {
                    if (state is AnalysisInitial) {
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

                    if (state is AnalysisLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryNeon,
                        ),
                      );
                    }

                    if (state is AnalysisFailure) {
                      return Center(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: AppTheme.accentRose),
                        ),
                      );
                    }

                    if (state is AnalysisSuccess) {
                      if (state.trendData.isEmpty) {
                        return const Center(
                          child: Text(
                            'No trend data found for this topic.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        );
                      }

                      return _buildCarouselContent(context, state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselContent(BuildContext context, AnalysisSuccess state) {
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
              'Keyword: ${state.keyword}',
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
                    return _buildPublicationTrendSlide(context, state.trendData, state.keyword);
                  } else if (pageIndex == 1) {
                    return _buildTopJournalsSlide(context, state.topJournals, state.keyword);
                  } else {
                    return _buildAuthorImpactSlide(context, state.topAuthors, state.keyword);
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

  // --- Slide 2: Top Research Journals (Ranked Horizontal Bars) ---
  Widget _buildTopJournalsSlide(BuildContext context, List<Map<String, dynamic>> journalsData, String keyword) {
    final topList = journalsData.where((data) {
      final name = data['key_display_name']?.toString().trim() ?? '';
      return name.isNotEmpty && name.toLowerCase() != 'unknown';
    }).take(5).toList();
    final maxCount = topList.isNotEmpty ? (topList.first['count'] as int? ?? 100).toDouble() : 100.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiagramHeader(title: 'Research Frontiers Discovery', topic: 'Identifying high velocity and growing keywords'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassBox(
              color: AppTheme.darkCardBackground.withValues(alpha: 0.4),
            ),
            child: topList.isEmpty
                ? const Center(child: Text('No journal data available', style: TextStyle(color: AppTheme.textSecondary)))
                : Column(
                    children: topList.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final data = entry.value;
                      final name = data['key_display_name']?.toString().trim() ?? '';
                      final count = data['count'] as int? ?? 0;
                      final ratio = maxCount > 0 ? count / maxCount : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNeon.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.35)),
                                  ),
                                  child: Text(
                                    '$rank',
                                    style: const TextStyle(
                                      color: AppTheme.primaryNeon,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$count papers',
                                  style: const TextStyle(
                                    color: AppTheme.secondaryNeon,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.borderNeon.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: ratio.clamp(0.05, 1.0).toDouble(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: const LinearGradient(
                                        colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Slide 3: Author Impact (Horizontal Bars) ---
  Widget _buildAuthorImpactSlide(BuildContext context, List<Map<String, dynamic>> authorsData, String keyword) {
    // Take top 5 authors to avoid list cluttering
    final topList = authorsData.take(5).toList();
    final maxCount = topList.isNotEmpty ? (topList.first['count'] as int? ?? 100).toDouble() : 100.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiagramHeader(title: 'Author & Collaboration Analytics', topic: 'Top authors by citation volume and publication index'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassBox(
              color: AppTheme.darkCardBackground.withValues(alpha: 0.4),
            ),
            child: topList.isEmpty
                ? const Center(child: Text('No authors available', style: TextStyle(color: AppTheme.textSecondary)))
                : Column(
                    children: topList.map((data) {
                      final name = data['key_display_name']?.toString() ?? 'Unknown';
                      final count = data['count'] as int? ?? 0;
                      final ratio = maxCount > 0 ? count / maxCount : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$count papers',
                                  style: const TextStyle(
                                    color: AppTheme.secondaryNeon,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.borderNeon.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: ratio.clamp(0.05, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: const LinearGradient(
                                        colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramHeader({required String title, required String topic}) {
    return Center(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryNeon,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            topic,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
