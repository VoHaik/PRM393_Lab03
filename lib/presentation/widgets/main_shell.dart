import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({required this.child, super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/analysis')) return 1;
    if (location.startsWith('/dashboard')) return 2;
    return 0; // Default to search
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/search');
        break;
      case 1:
        // Use query params to preserve search keyword context
        context.go('/analysis');
        break;
      case 2:
        context.go('/dashboard');
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
              icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.chartLine, size: 18),
              label: 'Trends',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.circleInfo, size: 18),
              label: 'Dashboard',
            ),
          ],
        ),
      ),
    );
  }
}
