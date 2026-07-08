import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/theme/app_theme.dart';
import '../viewmodels/journal_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';

class JournalDetailScreen extends StatefulWidget {
  final String journalId;
  final String displayName;

  const JournalDetailScreen({
    required this.journalId,
    required this.displayName,
    super.key,
  });

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyword = context.read<SearchViewModel>().keyword;
      context.read<JournalViewModel>().loadJournalDetail(widget.journalId, keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Consumer<JournalViewModel>(
          builder: (context, model, child) {
            if (model.isDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryNeon),
              );
            }

            if (model.detailErrorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.accentRose),
                      const SizedBox(height: 16),
                      Text(
                        model.detailErrorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final keyword = context.read<SearchViewModel>().keyword;
                          model.loadJournalDetail(widget.journalId, keyword);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final detail = model.selectedJournalDetail;
            if (detail == null) {
              return const Center(
                child: Text('No journal details available.', style: TextStyle(color: AppTheme.textSecondary)),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Journal Title Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNeon.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const FaIcon(FontAwesomeIcons.bookOpen, color: AppTheme.primaryNeon, size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'JOURNAL PROFILE',
                              style: TextStyle(
                                color: AppTheme.primaryNeon,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          detail.displayName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Publisher: ${detail.publisher}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Overall Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Total Papers',
                          value: detail.worksCount.toString(),
                          color: AppTheme.primaryNeon,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Total Citations',
                          value: detail.citedByCount.toString(),
                          color: AppTheme.secondaryNeon,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Avg Citations',
                          value: detail.averageCitations.toString(),
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Related Publications header
                  Text(
                    'Related Publications in current topic',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Related Publications List
                  Expanded(
                    child: detail.relatedPublications.isEmpty
                        ? const Center(
                            child: Text(
                              'No related publications found in this journal.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: detail.relatedPublications.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final pub = detail.relatedPublications[index];
                              return Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    context.push('/detail', extra: pub);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pub.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Year: ${pub.publicationYear}',
                                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                            ),
                                            Row(
                                              children: [
                                                const FaIcon(FontAwesomeIcons.quoteLeft, size: 10, color: AppTheme.secondaryNeon),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${pub.citedByCount} Citations',
                                                  style: const TextStyle(
                                                    color: AppTheme.secondaryNeon,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: AppTheme.glassBox(),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
