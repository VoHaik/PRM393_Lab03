import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../utils/theme/app_theme.dart';
import '../models/analytics_summary.dart';
import '../models/journal.dart';
import '../viewmodels/dashboard_viewmodel.dart';

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
                child: Consumer<DashboardViewModel>(
                  builder: (context, model, child) {
                    if (model.keyword.isEmpty && !model.isLoading && model.errorMessage == null) {
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

                    if (model.summary == null) {
                      return const Center(
                        child: Text(
                          'No dashboard data found.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    return _buildDashboardContent(context, model.summary!, model.keyword);
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(),
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
        ],
      ),
    );
  }

  Widget _buildJournalSources(AnalyticsSummary summary) {
    if (summary.topJournals.isEmpty) {
      return _buildDetailCard(
        icon: FontAwesomeIcons.bookOpen,
        title: 'N/A',
        subtitle: 'No journal sources metadata collected.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(),
      child: Column(
        children: List.generate(summary.topJournals.length, (idx) {
          final Journal journal = summary.topJournals[idx];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryNeon,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (idx + 1).toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    journal.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${journal.publicationCount} papers',
                  style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
