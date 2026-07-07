import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/publication.dart';

class DetailScreen extends StatelessWidget {
  final Publication publication;

  const DetailScreen({required this.publication, super.key});

  Future<void> _launchDoi(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Handle error launching URL silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publication Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Paper Title Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassBox(
                  color: AppTheme.darkCardBackground.withValues(alpha: 0.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Citation badge count on top right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryNeon.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            publication.publicationYear.toString(),
                            style: const TextStyle(
                              color: AppTheme.primaryNeon,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.quoteLeft, size: 10, color: AppTheme.secondaryNeon),
                            const SizedBox(width: 6),
                            Text(
                              '${publication.citedByCount} Citations',
                              style: const TextStyle(
                                color: AppTheme.secondaryNeon,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      publication.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Metadata info block
              Text(
                'Source Information',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNeon,
                    ),
              ),
              const SizedBox(height: 8),
              if (publication.journal != null) ...[
                _buildMetaInfoRow(
                  icon: const FaIcon(FontAwesomeIcons.bookOpen, size: 14, color: AppTheme.textSecondary),
                  label: 'Journal',
                  value: publication.journal!.displayName,
                ),
                _buildMetaInfoRow(
                  icon: const FaIcon(FontAwesomeIcons.building, size: 14, color: AppTheme.textSecondary),
                  label: 'Publisher',
                  value: publication.journal!.publisher,
                ),
                _buildMetaInfoRow(
                  icon: const FaIcon(FontAwesomeIcons.tag, size: 14, color: AppTheme.textSecondary),
                  label: 'Source Type',
                  value: publication.journal!.type.toUpperCase(),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No journal metadata available.',
                    style: TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Authors list
              Text(
                'Authors',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNeon,
                    ),
              ),
              const SizedBox(height: 8),
              if (publication.authors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: AppTheme.glassBox(),
                  child: Column(
                    children: publication.authors.map((author) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.userPen, size: 12, color: AppTheme.secondaryNeon),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    author.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (author.orcid.isNotEmpty)
                                    Text(
                                      author.orcid.replaceFirst('https://orcid.org/', 'ORCID: '),
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                const Text('Unknown Author(s)', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),

              // Abstract Card
              Text(
                'Abstract',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNeon,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassBox(
                  color: AppTheme.darkCardBackground.withValues(alpha: 0.4),
                ),
                child: Text(
                  publication.abstractText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // DOI Link launcher
              if (publication.doiUrl.isNotEmpty)
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchDoi(publication.doiUrl),
                      icon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare, size: 14),
                      label: const Text('Open Publisher Portal (DOI)'),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfoRow({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
