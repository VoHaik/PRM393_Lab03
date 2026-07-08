import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../injection_container.dart' as di;
import '../services/analytics_service.dart';
import '../utils/theme/app_theme.dart';
import '../viewmodels/analysis_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';

class KeywordDetailScreen extends StatefulWidget {
  final String keyword;
  final int count;

  const KeywordDetailScreen({
    required this.keyword,
    required this.count,
    super.key,
  });

  @override
  State<KeywordDetailScreen> createState() => _KeywordDetailScreenState();
}

class _KeywordDetailScreenState extends State<KeywordDetailScreen> {
  @override
  void initState() {
    super.initState();
    di.sl<AnalyticsService>().logViewKeyword(widget.keyword);
  }

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AnalysisViewModel>();
    final search = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyword Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.glassBox(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(FontAwesomeIcons.tag, color: AppTheme.primaryNeon, size: 20),
                  const SizedBox(height: 12),
                  Text(
                    widget.keyword,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.count} publications',
                    style: const TextStyle(
                      color: AppTheme.secondaryNeon,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Publication Trends',
              child: _TrendList(trendData: analysis.trendData),
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Related Journals',
              child: _GroupedList(
                items: analysis.topJournals,
                emptyMessage: 'No related journals available.',
                countLabel: 'publications',
              ),
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Top Authors',
              child: _GroupedList(
                items: analysis.topAuthors,
                emptyMessage: 'No author ranking available.',
                countLabel: 'works',
              ),
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Related Publications',
              child: search.publications.isEmpty
                  ? const Text(
                      'No related publications available.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  : Column(
                      children: search.publications.take(5).map((publication) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FaIcon(FontAwesomeIcons.bookOpen, size: 13, color: AppTheme.primaryNeon),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  publication.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassBox(),
          child: child,
        ),
      ],
    );
  }
}

class _TrendList extends StatelessWidget {
  final Map<int, int> trendData;

  const _TrendList({required this.trendData});

  @override
  Widget build(BuildContext context) {
    final years = trendData.keys.where((year) => year > 1950).toList()..sort();
    final recentYears = years.reversed.take(5).toList();

    if (recentYears.isEmpty) {
      return const Text(
        'No trend data available.',
        style: TextStyle(color: AppTheme.textSecondary),
      );
    }

    return Column(
      children: recentYears.map((year) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  year.toString(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _normalizedValue(year),
                    minHeight: 8,
                    backgroundColor: AppTheme.borderNeon,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${trendData[year] ?? 0}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  double _normalizedValue(int year) {
    final maxCount = trendData.values.isEmpty ? 1 : trendData.values.reduce((a, b) => a > b ? a : b);
    if (maxCount <= 0) return 0;
    return (trendData[year] ?? 0) / maxCount;
  }
}

class _GroupedList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String emptyMessage;
  final String countLabel;

  const _GroupedList({
    required this.items,
    required this.emptyMessage,
    required this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    final validItems = items.where((item) {
      final name = item['key_display_name']?.toString().trim() ?? '';
      return name.isNotEmpty && name.toLowerCase() != 'unknown';
    }).take(5).toList();

    if (validItems.isEmpty) {
      return Text(
        emptyMessage,
        style: const TextStyle(color: AppTheme.textSecondary),
      );
    }

    return Column(
      children: List.generate(validItems.length, (index) {
        final item = validItems[index];
        final name = item['key_display_name']?.toString() ?? 'Unknown';
        final count = item['count'] as int? ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryNeon,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count $countLabel',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
