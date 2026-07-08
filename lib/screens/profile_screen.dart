import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _triggerExport(BuildContext context) async {
    final searchVM = context.read<SearchViewModel>();
    final dashboardVM = context.read<DashboardViewModel>();
    final profileVM = context.read<ProfileViewModel>();

    final topic = searchVM.keyword;
    final summary = dashboardVM.summary;

    if (topic.isEmpty || summary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search for a topic on the Home tab first to generate a report.'),
          backgroundColor: AppTheme.accentRose,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircularProgressIndicator(color: AppTheme.primaryNeon),
                SizedBox(width: 20),
                Expanded(child: Text('Generating PDF & uploading to Firebase Storage...')),
              ],
            ),
          ),
        );
      },
    );

    // Call export
    await profileVM.exportAndUploadReport(summary, topic);

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Show result dialog
    if (profileVM.exportError != null) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Export Failed'),
              content: Text(profileVM.exportError!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else if (profileVM.uploadedUrl != null) {
      final url = profileVM.uploadedUrl!;
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Export Successful'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Report uploaded successfully to Firebase Storage!'),
                  const SizedBox(height: 12),
                  SelectableText(
                    url,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryNeon,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy Link'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied link to clipboard.')),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                  label: const Text('Open'),
                  onPressed: () async {
                    final uri = Uri.parse(url);
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open browser: $e')),
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.circleUser, color: AppTheme.primaryNeon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'User Settings & Labs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Manage account & view Firebase services demos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // User Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassBox(),
                child: Column(
                  children: [
                    // Avatar Image
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.borderNeon,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null
                          ? const FaIcon(FontAwesomeIcons.user, size: 36, color: AppTheme.textSecondary)
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Display Name
                    Text(
                      user?.displayName ?? 'Anonymous User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email Address
                    Text(
                      user?.email ?? 'No email associated',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await authViewModel.signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accentRose),
                          foregroundColor: AppTheme.accentRose,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 14),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Demos Heading
              const Text(
                'Firebase Services Demo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),

              // Demos List Cards
              _buildDemoCard(
                icon: FontAwesomeIcons.bell,
                title: 'Notification Center (FCM)',
                subtitle: 'Push notifications logs received from FCM Console.',
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 12),

              _buildDemoCard(
                icon: FontAwesomeIcons.filePdf,
                title: 'Report Export & Storage',
                subtitle: 'Export data to PDF and upload to Firebase Storage.',
                color: Colors.deepOrangeAccent,
                onTap: () => _triggerExport(context),
              ),
              const SizedBox(height: 12),

              _buildDemoCard(
                icon: FontAwesomeIcons.sliders,
                title: 'Remote Config Demo',
                subtitle: 'Dynamically configure parameters from remote values.',
                color: Colors.purpleAccent,
              ),
              const SizedBox(height: 12),

              _buildDemoCard(
                icon: FontAwesomeIcons.bugSlash,
                title: 'Crashlytics Demo',
                subtitle: 'Generate crash reports & exceptions testing console.',
                color: Colors.redAccent,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required FaIconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassBox(
            color: AppTheme.darkCardBackground.withValues(alpha: onTap != null ? 0.8 : 0.6),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: color, size: 16),
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
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: onTap != null ? AppTheme.primaryNeon : AppTheme.borderNeon,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
