import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/analytics_summary.dart';

class ReportService {
  Future<Uint8List> generatePdfReport(AnalyticsSummary summary, String topic) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Scientia Analytics',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        DateTime.now().toLocal().toString().substring(0, 16),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Title
                pw.Text(
                  'RESEARCH TRENDS REPORT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Analyzed Topic: $topic',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 24),

                // Core Metrics Section
                pw.Text(
                  '1. Key Bibliometric Metrics',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPdfStatItem('Total Publications', summary.totalPublications.toString()),
                    _buildPdfStatItem('Average Citations (Top 50)', summary.averageCitations.toString()),
                    _buildPdfStatItem('Peak Publication Year', summary.peakYear > 0 ? summary.peakYear.toString() : 'N/A'),
                  ],
                ),
                pw.SizedBox(height: 32),

                // Key Insights / Entities
                pw.Text(
                  '2. Top Research Entities',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 8),

                // Top Journal
                _buildPdfDetailItem(
                  'Top Journal Source',
                  summary.topJournal?.displayName ?? 'N/A',
                  summary.topJournal != null 
                      ? 'Total Publications in search: ${summary.topJournal!.publicationCount} papers'
                      : '',
                ),
                pw.SizedBox(height: 12),

                // Top Author
                _buildPdfDetailItem(
                  'Top Contributing Author',
                  summary.topAuthor?.displayName ?? 'N/A',
                  summary.topAuthor != null 
                      ? '${summary.topAuthor!.institution ?? 'No institution recorded'} • Works: ${summary.topAuthor!.worksCount ?? 0} • Citations: ${summary.topAuthor!.citedByCount ?? 0}'
                      : '',
                ),
                pw.SizedBox(height: 12),

                // Most Cited Paper
                _buildPdfDetailItem(
                  'Most Influential Publication',
                  summary.topPaper?.title ?? 'N/A',
                  summary.topPaper != null
                      ? 'Published: ${summary.topPaper!.publicationYear} • Citations: ${summary.topPaper!.citedByCount} • DOI: ${summary.topPaper!.doiUrl}'
                      : '',
                ),
                
                pw.Spacer(),
                // Footer
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Generated automatically by Journal Trend Analyzer',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfStatItem(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfDetailItem(String header, String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          header,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        if (subtitle.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(subtitle, style: const pw.TextStyle(fontSize: 10)),
        ],
      ],
    );
  }
}
