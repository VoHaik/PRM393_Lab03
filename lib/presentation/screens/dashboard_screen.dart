import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/journal.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  final String keyword;

  const DashboardScreen({this.keyword = '', super.key});

  @override
  Widget build(BuildContext context) {
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
                  const FaIcon(FontAwesomeIcons.gaugeHigh, color: AppTheme.primaryNeon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Research Ecosystem Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Aggregated publication analytics & insights',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardInitial) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.chartSimple,
                              size: 64,
                              color: AppTheme.borderNeon,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Please perform a search in the Search tab to view dashboard analytics.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is DashboardLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryNeon,
                        ),
                      );
                    }

                    if (state is DashboardFailure) {
                      return Center(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: AppTheme.accentRose),
                        ),
                      );
                    }

                    if (state is DashboardSuccess) {
                      return _buildDashboardContent(context, state.summary, state.keyword);
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

  Widget _buildDashboardContent(BuildContext context, AnalyticsSummary summary, String keyword) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keyword Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Topic Analysis: $keyword',
              style: const TextStyle(
                color: AppTheme.primaryNeon,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

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
          const SizedBox(height: 24),

          // Top Contributing Journals
          const Text(
            'Top Journal Sources',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          _buildJournalSources(summary),
          const SizedBox(height: 20),

          // Top Contributing Author
          Builder(
            builder: (context) {
              final author = summary.topAuthor;
              String authorSubtitle = 'No author metadata available.';
              if (author != null) {
                final parts = <String>[];
                if (author.institution != null && author.institution!.isNotEmpty) {
                  parts.add(author.institution!);
                }
                if (author.orcid.isNotEmpty) {
                  parts.add('ORCID: ${author.orcid.replaceFirst("https://orcid.org/", "")}');
                }
                if (author.worksCount != null && author.worksCount! > 0) {
                  parts.add('${author.worksCount} publications');
                }
                if (author.citedByCount != null && author.citedByCount! > 0) {
                  parts.add('${author.citedByCount} citations');
                }
                if (parts.isNotEmpty) {
                  authorSubtitle = parts.join(' • ');
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Contribution',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailCard(
                    icon: FontAwesomeIcons.userPen,
                    title: author?.displayName ?? 'N/A',
                    subtitle: authorSubtitle,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Most Influential Paper Card
          const Text(
            'Most Influential Paper',
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }

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
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              FaIcon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.borderNeon.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: AppTheme.primaryNeon, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalSources(AnalyticsSummary summary) {
    final journals = summary.topJournals.isNotEmpty
        ? summary.topJournals
        : [
            if (summary.topJournal != null) summary.topJournal!,
          ];

    if (journals.isEmpty) {
      return _buildDetailCard(
        icon: FontAwesomeIcons.bookOpen,
        title: 'N/A',
        subtitle: 'No source publication data recorded.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(),
      child: Column(
        children: journals.asMap().entries.map((entry) {
          final index = entry.key;
          final journal = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index == journals.length - 1 ? 0 : 12),
            child: _buildJournalRow(index + 1, journal),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJournalRow(int rank, Journal journal) {
    final countText = journal.publicationCount > 0 ? '${journal.publicationCount} papers' : journal.type;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            journal.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          countText,
          style: const TextStyle(color: AppTheme.secondaryNeon, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
