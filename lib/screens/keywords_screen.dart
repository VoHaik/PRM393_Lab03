import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../utils/theme/app_theme.dart';
import '../viewmodels/analysis_viewmodel.dart';

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
                child: Consumer<AnalysisViewModel>(
                  builder: (context, model, child) {
                    if (model.keyword.isEmpty && !model.isLoading && model.errorMessage == null) {
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

                    final keywords = _validKeywords(model.topKeywords);
                    if (keywords.isEmpty) {
                      return const _EmptyState(
                        icon: FontAwesomeIcons.tags,
                        message: 'No keyword analytics available for this topic.',
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Topic: ${model.keyword}',
                            style: const TextStyle(
                              color: AppTheme.primaryNeon,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: keywords.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final keyword = keywords[index];
                              final name = keyword['key_display_name']?.toString() ?? 'Unknown';
                              final count = keyword['count'] as int? ?? 0;
                              return _KeywordCard(
                                rank: index + 1,
                                name: name,
                                count: count,
                                onTap: () {
                                  context.push(
                                    '/keyword-detail',
                                    extra: {
                                      'keyword': name,
                                      'count': count,
                                    },
                                  );
                                },
                              );
                            },
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

  static List<Map<String, dynamic>> _validKeywords(List<Map<String, dynamic>> source) {
    return source.where((item) {
      final name = item['key_display_name']?.toString().trim() ?? '';
      return name.isNotEmpty && name.toLowerCase() != 'unknown';
    }).toList();
  }
}

class _KeywordCard extends StatelessWidget {
  final int rank;
  final String name;
  final int count;
  final VoidCallback onTap;

  const _KeywordCard({
    required this.rank,
    required this.name,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                      name,
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
                      '$count publications',
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
