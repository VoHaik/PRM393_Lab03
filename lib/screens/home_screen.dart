import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/theme/app_theme.dart';
import '../models/publication.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/analysis_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/keyword_viewmodel.dart';
import '../viewmodels/journal_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<String> _quickTopics = [
    'Artificial Intelligence',
    'Cybersecurity',
    'Blockchain',
    'Data Science',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _triggerSearch(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) return;
    _searchController.text = trimmedKeyword;
    
    // 1. Dispatch search
    await context.read<SearchViewModel>().searchTopic(trimmedKeyword);
    
    if (!mounted) return;
    
    // 2. Pre-fetch trends (Analysis)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<AnalysisViewModel>().fetchAnalysis(trimmedKeyword);
    
    // 3. Pre-fetch keywords
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<KeywordViewModel>().loadForTopic(trimmedKeyword);

    // 4. Pre-fetch dashboard overview
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<DashboardViewModel>().fetchDashboard(trimmedKeyword);

    // 5. Pre-fetch journals
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<JournalViewModel>().loadForTopic(trimmedKeyword);
  }

  @override
  Widget build(BuildContext context) {
    final searchViewModel = context.watch<SearchViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                    ).createShader(bounds),
                    child: const FaIcon(
                      FontAwesomeIcons.graduationCap,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scientia Analytics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Comprehensive bibliometric analysis platform',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                onSubmitted: _triggerSearch,
                decoration: InputDecoration(
                  hintText: 'Search topic (e.g. Machine Learning)...',
                  prefixIcon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryNeon),
                    onPressed: () => _triggerSearch(_searchController.text),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Topics Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickTopics.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final topic = _quickTopics[index];
                    return GestureDetector(
                      onTap: () => _triggerSearch(topic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: AppTheme.glassBox(
                          color: AppTheme.darkCardBackground.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          topic,
                          style: const TextStyle(
                            color: AppTheme.primaryNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Content conditional state logic
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (searchViewModel.keyword.isEmpty &&
                        !searchViewModel.isLoading &&
                        searchViewModel.errorMessage == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.magnifyingGlassChart,
                              size: 64,
                              color: AppTheme.borderNeon,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Search for a topic above or tap a quick chip to start analyzing.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    if (searchViewModel.isLoading) {
                      return _buildShimmerLoader();
                    }

                    if (searchViewModel.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppTheme.accentRose,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchViewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _triggerSearch(_searchController.text),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab Bar to switch between Dashboard, Trend Chart, and Publications
                        TabBar(
                          controller: _tabController,
                          labelColor: AppTheme.primaryNeon,
                          unselectedLabelColor: AppTheme.textSecondary,
                          indicatorColor: AppTheme.primaryNeon,
                          tabs: const [
                            Tab(text: 'Dashboard'),
                            Tab(text: 'Trend Chart'),
                            Tab(text: 'Papers'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildDashboardTab(context),
                              _buildTrendsTab(context),
                              _buildPublicationsTab(context, searchViewModel.publications, searchViewModel.keyword),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Tab 1: Dashboard overview stats ---
  Widget _buildDashboardTab(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon));
        }

        if (model.errorMessage != null) {
          return Center(
            child: Text(
              model.errorMessage!,
              style: const TextStyle(color: AppTheme.accentRose),
            ),
          );
        }

        final summary = model.summary;
        if (summary == null) {
          return const Center(
            child: Text('No dashboard summary data available.', style: TextStyle(color: AppTheme.textSecondary)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numeric Cards Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.45,
                children: [
                  _buildStatCard(
                    icon: FontAwesomeIcons.book,
                    title: 'Total Works',
                    value: summary.totalPublications.toString(),
                    color: AppTheme.primaryNeon,
                  ),
                  _buildStatCard(
                    icon: FontAwesomeIcons.quoteLeft,
                    title: 'Avg Citations',
                    value: summary.averageCitations.toString(),
                    color: AppTheme.secondaryNeon,
                  ),
                  _buildStatCard(
                    icon: FontAwesomeIcons.rankingStar,
                    title: 'Peak Year',
                    value: summary.peakYear > 0 ? summary.peakYear.toString() : 'N/A',
                    color: Colors.amber,
                  ),
                  _buildStatCard(
                    icon: FontAwesomeIcons.chartPie,
                    title: 'Sampled Base',
                    value: 'Top 50 papers',
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Top Journal Card
              const Text(
                'Top Journal Source',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              if (summary.topJournal != null)
                _buildDetailCard(
                  icon: FontAwesomeIcons.bookOpen,
                  title: summary.topJournal!.displayName,
                  subtitle: '${summary.topJournal!.publicationCount} papers in searched dataset',
                  onTap: () {
                    context.push(
                      '/journal-detail',
                      extra: {
                        'journalId': summary.topJournal!.id,
                        'displayName': summary.topJournal!.displayName,
                      },
                    );
                  },
                )
              else
                _buildDetailCard(
                  icon: FontAwesomeIcons.bookOpen,
                  title: 'N/A',
                  subtitle: 'No journal information available',
                ),
              const SizedBox(height: 20),

              // Top Author Card
              const Text(
                'Top Contribution',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final author = summary.topAuthor;
                  String subtitle = 'No author statistics recorded.';
                  if (author != null) {
                    final parts = <String>[];
                    if (author.institution != null && author.institution!.isNotEmpty) {
                      parts.add(author.institution!);
                    }
                    if (author.orcid.isNotEmpty) {
                      parts.add('ORCID: ${author.orcid.replaceFirst("https://orcid.org/", "")}');
                    }
                    if (author.worksCount != null) {
                      parts.add('${author.worksCount} works');
                    }
                    if (parts.isNotEmpty) {
                      subtitle = parts.join(' • ');
                    }
                  }
                  return _buildDetailCard(
                    icon: FontAwesomeIcons.userPen,
                    title: author?.displayName ?? 'N/A',
                    subtitle: subtitle,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Most Influential Publication Card
              const Text(
                'Most Influential Publication',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              if (summary.topPaper != null)
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.push('/detail', extra: summary.topPaper);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const FaIcon(FontAwesomeIcons.crown, color: Colors.amber, size: 16),
                              Row(
                                children: [
                                  const FaIcon(FontAwesomeIcons.quoteLeft, size: 10, color: AppTheme.secondaryNeon),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${summary.topPaper!.citedByCount} Citations',
                                    style: const TextStyle(
                                      color: AppTheme.secondaryNeon,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            summary.topPaper!.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Published: ${summary.topPaper!.publicationYear} • Tap to view details',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                _buildDetailCard(
                  icon: FontAwesomeIcons.crown,
                  title: 'N/A',
                  subtitle: 'No publication recorded.',
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- Sub-Tab 2: Publication Trend Line Chart ---
  Widget _buildTrendsTab(BuildContext context) {
    return Consumer<AnalysisViewModel>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon));
        }

        if (model.errorMessage != null) {
          return Center(
            child: Text(
              model.errorMessage!,
              style: const TextStyle(color: AppTheme.accentRose),
            ),
          );
        }

        final trendData = model.trendData;
        if (trendData.isEmpty) {
          return const Center(
            child: Text('No trend data found for this topic.', style: TextStyle(color: AppTheme.textSecondary)),
          );
        }

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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ecosystem Flux',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Multi-dimensional analysis of research velocity',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              // Chart Container
              Container(
                height: 240,
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
                              if (idx == 0 ||
                                  idx == filteredYears.length - 1 ||
                                  idx == (filteredYears.length / 2).floor()) {
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
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- Sub-Tab 3: Publications list results ---
  Widget _buildPublicationsTab(BuildContext context, List<Publication> publications, String keyword) {
    if (publications.isEmpty) {
      return const Center(
        child: Text(
          'No publications found. Try another search query.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Results for "$keyword"',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: publications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pub = publications[index];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.push('/detail', extra: pub);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pub.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (pub.journal != null)
                          Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.bookOpen, size: 12, color: AppTheme.primaryNeon),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  pub.journal!.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        if (pub.authors.isNotEmpty)
                          Text(
                            pub.authors.map((a) => a.displayName).join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.borderNeon.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pub.publicationYear.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.quoteLeft,
                                  size: 12,
                                  color: AppTheme.secondaryNeon,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${pub.citedByCount} Citations',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryNeon,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper elements
  Widget _buildStatCard({
    required FaIconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              FaIcon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required FaIconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.glassBox(),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: AppTheme.primaryNeon, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Center(
                  child: Icon(Icons.chevron_right_rounded, color: AppTheme.primaryNeon),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkCardBackground,
      highlightColor: AppTheme.borderNeon,
      child: ListView.separated(
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.darkCardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
