/// screens/main_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_devices_screen.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import '../providers/notifications_provider.dart';
import '../core/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MyDevicesScreen(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard),
            selectedIcon: const Icon(Icons.dashboard, color: AppTheme.primaryColor),
            label: 'لوحة التحكم',
          ),
          NavigationDestination(
            icon: const Icon(Icons.developer_board),
            selectedIcon: const Icon(Icons.developer_board, color: AppTheme.primaryColor),
            label: 'الأجهزة',
          ),
          NavigationDestination(
            icon: Consumer<NotificationsProvider>(
              builder: (context, notifProvider, _) {
                return Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notifProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            selectedIcon: const Icon(Icons.notifications, color: AppTheme.primaryColor),
            label: 'الإشعارات',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            selectedIcon: const Icon(Icons.settings, color: AppTheme.primaryColor),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
