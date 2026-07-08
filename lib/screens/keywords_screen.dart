import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/keyword_analytics.dart';
import '../utils/theme/app_theme.dart';
import '../viewmodels/keyword_viewmodel.dart';

class KeywordsScreen extends StatelessWidget {
  const KeywordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.tags, color: AppTheme.primaryNeon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Keywords',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Frequent research topics from the latest search',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<KeywordViewModel>(
                  builder: (context, model, child) {
                    if (model.topic.isEmpty && !model.isLoading && model.errorMessage == null) {
                      return const _EmptyState(
                        icon: FontAwesomeIcons.magnifyingGlassChart,
                        message: 'Search for a topic first to view keyword analytics.',
                      );
                    }

                    if (model.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryNeon),
                      );
                    }

                    if (model.errorMessage != null) {
                      return Center(
                        child: Text(
                          model.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.accentRose),
                        ),
                      );
                    }

                    final keywords = model.keywords;
                    if (keywords.isEmpty) {
                      return const _EmptyState(
                        icon: FontAwesomeIcons.tags,
                        message: 'No keyword analytics available for this topic.',
                      );
                    }

                    return ListView(
                      children: [
                        _TopicChip(topic: model.topic),
                        const SizedBox(height: 16),
                        const _SectionTitle('Most Frequent Keywords'),
                        ...List.generate(
                          model.mostFrequentKeywords.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _KeywordCard(
                              rank: index + 1,
                              keyword: model.mostFrequentKeywords[index],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _SectionTitle('Trending Keywords'),
                        ...model.trendingKeywords.take(3).map(
                              (keyword) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _TrendingKeywordCard(keyword: keyword),
                              ),
                            ),
                        const SizedBox(height: 8),
                        const _SectionTitle('Keyword Frequency Statistics'),
                        ...model.mostFrequentKeywords.take(3).map(
                              (keyword) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _KeywordStatsCard(keyword: keyword),
                              ),
                            ),
                        const SizedBox(height: 8),
                        const _SectionTitle('Keyword Trend Charts'),
                        ...model.mostFrequentKeywords.take(3).map(
                              (keyword) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _KeywordTrendPreview(keyword: keyword),
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

}

class _KeywordCard extends StatelessWidget {
  final int rank;
  final KeywordAnalytics keyword;

  const _KeywordCard({
    required this.rank,
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push(
            '/keyword-detail',
            extra: {
              'keyword': keyword.name,
              'count': keyword.publicationCount,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNeon,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      keyword.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${keyword.publicationCount} publications',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryNeon),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String topic;

  const _TopicChip({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryNeon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Topic: $topic',
        style: const TextStyle(
          color: AppTheme.primaryNeon,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _TrendingKeywordCard extends StatelessWidget {
  final KeywordAnalytics keyword;

  const _TrendingKeywordCard({required this.keyword});

  @override
  Widget build(BuildContext context) {
    final growthPrefix = keyword.growth >= 0 ? '+' : '';
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const FaIcon(
          FontAwesomeIcons.arrowTrendUp,
          color: AppTheme.secondaryNeon,
          size: 18,
        ),
        title: Text(
          keyword.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Growth $growthPrefix${keyword.growth} publications',
        ),
        trailing: Text(
          '${keyword.growthRate}%',
          style: const TextStyle(
            color: AppTheme.secondaryNeon,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _KeywordStatsCard extends StatelessWidget {
  final KeywordAnalytics keyword;

  const _KeywordStatsCard({required this.keyword});

  @override
  Widget build(BuildContext context) {
    final growthPrefix = keyword.growth >= 0 ? '+' : '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              keyword.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${keyword.publicationCount} publications'),
            Text('${keyword.percentage}% of matching topic publications'),
            Text(
              'Most active year: ${keyword.mostActiveYear == 0 ? 'N/A' : keyword.mostActiveYear}',
            ),
            Text('Growth: $growthPrefix${keyword.growth} publications'),
          ],
        ),
      ),
    );
  }
}

class _KeywordTrendPreview extends StatelessWidget {
  final KeywordAnalytics keyword;

  const _KeywordTrendPreview({required this.keyword});

  @override
  Widget build(BuildContext context) {
    final years = keyword.trendByYear.keys.toList()..sort();
    final recentYears = years.reversed.take(5).toList().reversed.toList();
    final maxCount = keyword.trendByYear.values.isEmpty
        ? 1
        : keyword.trendByYear.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              keyword.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...recentYears.map(
              (year) {
                final count = keyword.trendByYear[year] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 48, child: Text('$year')),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: maxCount == 0 ? 0 : count / maxCount,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$count'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final FaIconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 64, color: AppTheme.borderNeon),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
