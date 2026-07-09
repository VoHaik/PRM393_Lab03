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
import '../services/fcm_service.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
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
      ),
    );

    await profileVM.exportAndUploadReport(summary, topic);

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    if (profileVM.exportError != null) {
      if (context.mounted) {
        _showErrorDialog(context, 'Export Failed', profileVM.exportError!);
      }
    } else if (profileVM.uploadedUrl != null) {
      final url = profileVM.uploadedUrl!;
      if (context.mounted) {
        _showUploadSuccessDialog(context, url);
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showUploadSuccessDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report uploaded successfully to Firebase Storage!'),
            const SizedBox(height: 12),
            SelectableText(
              url,
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryNeon, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Link'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Copied link to clipboard.')));
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Could not open browser: $e')));
                }
              }
            },
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final profileVM = context.watch<ProfileViewModel>();
    final user = authViewModel.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.circleUser, color: AppTheme.primaryNeon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'User Settings & Labs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Manage account & view Firebase services demos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 1. USER INFO CARD
              // ============================================================
              _SectionCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.borderNeon,
                      backgroundImage:
                          user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null
                          ? const FaIcon(FontAwesomeIcons.user, size: 36, color: AppTheme.textSecondary)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'Anonymous User',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'No email associated',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('sign_out_button'),
                        onPressed: () async {
                          await authViewModel.signOut();
                          if (context.mounted) context.go('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accentRose),
                          foregroundColor: AppTheme.accentRose,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 14),
                        label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 2. NOTIFICATION CENTER (FCM)
              // ============================================================
              _SectionHeader(
                icon: FontAwesomeIcons.bell,
                title: 'Notification Center (FCM)',
                color: Colors.blueAccent,
                trailing: profileVM.notifications.isNotEmpty
                    ? TextButton(
                        onPressed: profileVM.clearNotifications,
                        child: const Text('Clear all', style: TextStyle(fontSize: 12)),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              _SectionCard(
                key: const Key('notification_center_section'),
                child: profileVM.notifications.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No notifications yet.\nSend a test message from Firebase Console → Cloud Messaging.',
                                key: Key('no_notification_placeholder'),
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: profileVM.notifications
                            .map((n) => _NotificationItem(notification: n))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 3. REPORT EXPORT & STORAGE
              // ============================================================
              const _SectionHeader(
                icon: FontAwesomeIcons.filePdf,
                title: 'Report Export & Storage',
                color: Colors.deepOrangeAccent,
              ),
              const SizedBox(height: 8),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export the current dashboard analytics as a PDF and upload it to Firebase Storage.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const Key('export_pdf_button'),
                        onPressed: () => _triggerExport(context),
                        icon: const FaIcon(FontAwesomeIcons.fileArrowDown, size: 14),
                        label: const Text('Export & Upload PDF'),
                      ),
                    ),
                    if (profileVM.uploadedUrl != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                key: const Key('upload_url_display'),
                                profileVM.uploadedUrl!,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 4. REMOTE CONFIG DEMO
              // ============================================================
              const _SectionHeader(
                icon: FontAwesomeIcons.sliders,
                title: 'Remote Config Demo',
                color: Colors.purpleAccent,
              ),
              const SizedBox(height: 8),
              _SectionCard(
                key: const Key('remote_config_section'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fetch live configuration values from Firebase Remote Config.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const Key('fetch_remote_config_button'),
                        onPressed: profileVM.isLoadingConfig ? null : profileVM.fetchRemoteConfig,
                        icon: profileVM.isLoadingConfig
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const FaIcon(FontAwesomeIcons.cloudArrowDown, size: 14),
                        label: Text(profileVM.isLoadingConfig ? 'Fetching...' : 'Fetch Remote Config'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      ),
                    ),
                    if (profileVM.configFetched) ...[
                      const SizedBox(height: 12),
                      _ConfigValueRow(
                        key: const Key('max_journals_config_value'),
                        label: 'max_journals_display',
                        value: profileVM.maxJournalsDisplay.toString(),
                        icon: FontAwesomeIcons.bookOpen,
                      ),
                      const SizedBox(height: 8),
                      _ConfigValueRow(
                        key: const Key('max_keywords_config_value'),
                        label: 'max_keywords_display',
                        value: profileVM.maxKeywordsDisplay.toString(),
                        icon: FontAwesomeIcons.tags,
                      ),
                    ],
                    if (profileVM.configError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${profileVM.configError}',
                        style: const TextStyle(color: AppTheme.accentRose, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 5. CRASHLYTICS DEMO
              // ============================================================
              const _SectionHeader(
                icon: FontAwesomeIcons.bugSlash,
                title: 'Crashlytics Demo',
                color: Colors.redAccent,
              ),
              const SizedBox(height: 8),
              _SectionCard(
                key: const Key('crashlytics_section'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate test exceptions and crashes to verify Firebase Crashlytics monitoring.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('handled_exception_button'),
                            onPressed: profileVM.triggerHandledException,
                            icon: const Icon(Icons.warning_amber_rounded, size: 16),
                            label: const Text('Handled\nException', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.orange),
                              foregroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('test_crash_button'),
                            onPressed: () => _confirmAndCrash(context, profileVM),
                            icon: const Icon(Icons.bolt_rounded, size: 16),
                            label: const Text('Force\nCrash', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (profileVM.crashlyticsMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          key: const Key('crashlytics_result_message'),
                          profileVM.crashlyticsMessage!,
                          style: const TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAndCrash(BuildContext context, ProfileViewModel profileVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Force Crash Test'),
        content: const Text(
          'This will intentionally crash the app to test Firebase Crashlytics.\n\nCheck the Firebase Crashlytics Console after restarting the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              profileVM.triggerTestCrash();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Crash Now'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELPER WIDGETS
// ============================================================

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final FaIconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: FaIcon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_active_rounded, color: Colors.blueAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(notification.body, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
                const SizedBox(height: 4),
                Text(
                  '${notification.receivedAt.hour.toString().padLeft(2, '0')}:${notification.receivedAt.minute.toString().padLeft(2, '0')} - ${notification.receivedAt.day}/${notification.receivedAt.month}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigValueRow extends StatelessWidget {
  final String label;
  final String value;
  final FaIconData icon;

  const _ConfigValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: Colors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
