import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/theme/app_theme.dart';
import '../viewmodels/journal_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';

class JournalsScreen extends StatelessWidget {
  const JournalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalModel = context.watch<JournalViewModel>();
    final searchModel = context.watch<SearchViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.bookOpen, color: AppTheme.primaryNeon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Journals Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Journal-level bibliometrics for the active research topic',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Builder(
                  builder: (context) {
                    if (journalModel.topic.isEmpty && !journalModel.isLoading && journalModel.errorMessage == null) {
                      return const _EmptyState(
                        icon: FontAwesomeIcons.magnifyingGlassChart,
                        message: 'Search for a topic on the Home tab first to view journal analytics.',
                      );
                    }

                    if (journalModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryNeon),
                      );
                    }

                    if (journalModel.errorMessage != null) {
                      return Center(
                        child: Text(
                          journalModel.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.accentRose),
                        ),
                      );
                    }

                    final journals = journalModel.journals;
                    if (journals.isEmpty) {
                      return const _EmptyState(
                        icon: FontAwesomeIcons.bookOpen,
                        message: 'No journal statistics available for this topic.',
                      );
                    }

                    // Extract citation statistics by journal from search results locally
                    final Map<String, int> journalCitations = {};
                    final Map<String, int> journalPubsInTop50 = {};
                    for (var pub in searchModel.publications) {
                      if (pub.journal != null && pub.journal!.displayName.isNotEmpty) {
                        final jName = pub.journal!.displayName;
                        journalCitations[jName] = (journalCitations[jName] ?? 0) + pub.citedByCount;
                        journalPubsInTop50[jName] = (journalPubsInTop50[jName] ?? 0) + 1;
                      }
                    }

                    // Sort journals by citations for citation stats section
                    final sortedCitationJournals = journalCitations.keys.toList()
                      ..sort((a, b) => journalCitations[b]!.compareTo(journalCitations[a]!));

                    return ListView(
                      children: [
                        _TopicChip(topic: journalModel.topic),
                        const SizedBox(height: 16),

                        // Section 1: Ranked list of top journals
                        const _SectionTitle('Top Journals (Ranked by volume)'),
                        ...List.generate(
                          journals.length,
                          (index) {
                            final j = journals[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _JournalCard(
                                rank: index + 1,
                                name: j.displayName,
                                publisher: j.publisher,
                                publicationCount: j.publicationCount,
                                onTap: () {
                                  context.push(
                                    '/journal-detail',
                                    extra: {
                                      'journalId': j.id,
                                      'displayName': j.displayName,
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Section 2: Journal contribution chart
                        const _SectionTitle('Journal Contribution (Publication shares)'),
                        _buildContributionChart(journals, journalModel.totalPublicationsInTopJournals),
                        const SizedBox(height: 24),

                        // Section 3: Citation statistics by journal
                        const _SectionTitle('Citation Volume by Journal (Top Papers)'),
                        if (sortedCitationJournals.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No citation data matches in search results.', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                          )
                        else
                          ...sortedCitationJournals.take(5).map(
                            (jName) {
                              final citations = journalCitations[jName] ?? 0;
                              final papers = journalPubsInTop50[jName] ?? 0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _JournalCitationCard(
                                  name: jName,
                                  citationCount: citations,
                                  paperCount: papers,
                                ),
                              );
                            },
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

  Widget _buildContributionChart(List<dynamic> journals, double totalVolume) {
    if (totalVolume == 0) totalVolume = 1;
    final displayJournals = journals.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayJournals.map((j) {
            final double percentage = j.publicationCount / totalVolume;
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
                          j.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(percentage * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 12, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final int rank;
  final String name;
  final String publisher;
  final int publicationCount;
  final VoidCallback onTap;

  const _JournalCard({
    required this.rank,
    required this.name,
    required this.publisher,
    required this.publicationCount,
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      publisher,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$publicationCount',
                    style: const TextStyle(
                      color: AppTheme.primaryNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    'papers',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryNeon),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalCitationCard extends StatelessWidget {
  final String name;
  final int citationCount;
  final int paperCount;

  const _JournalCitationCard({
    required this.name,
    required this.citationCount,
    required this.paperCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNeon.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.quoteLeft,
                color: AppTheme.secondaryNeon,
                size: 16,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From $paperCount papers in top results',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$citationCount citations',
              style: const TextStyle(
                color: AppTheme.secondaryNeon,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
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
