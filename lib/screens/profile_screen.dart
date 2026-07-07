import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../utils/theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

              // Demos List Cards (Placeholders for upcoming phases)
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassBox(
        color: AppTheme.darkCardBackground.withValues(alpha: 0.6),
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
          const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.borderNeon, size: 12),
        ],
      ),
    );
  }
}
