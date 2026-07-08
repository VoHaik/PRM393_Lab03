import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({required this.child, super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/journals') || location.startsWith('/journal-detail')) return 1;
    if (location.startsWith('/keywords') || location.startsWith('/keyword-detail')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // Default to /home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/journals');
        break;
      case 2:
        context.go('/keywords');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.borderNeon.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.darkCardBackground.withValues(alpha: 0.95),
          selectedItemColor: AppTheme.primaryNeon,
          unselectedItemColor: AppTheme.textSecondary,
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, size: 18),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.bookOpen, size: 18),
              label: 'Journals',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.tags, size: 18),
              label: 'Keywords',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.circleUser, size: 18),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
