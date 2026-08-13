/// screens/dashboard_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/user_provider.dart';
import '../providers/notifications_provider.dart';
import '../core/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
      
      userProvider.loadCurrentUser();
      notificationsProvider.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.loadCurrentUser();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// بطاقة الترحيب
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Card(
                      color: AppTheme.primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أهلاً وسهلاً',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userProvider.currentUser?.displayName ?? 'المستخدم',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                /// الإحصائيات السريعة
                Text(
                  'الإحصائيات',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      icon: Icons.developer_board,
                      label: 'الأجهزة النشطة',
                      value: '5',
                      color: AppTheme.successColor,
                    ),
                    _buildStatCard(
                      icon: Icons.devices_off,
                      label: 'الأجهزة المعطلة',
                      value: '1',
                      color: AppTheme.errorColor,
                    ),
                    _buildStatCard(
                      icon: Icons.notifications,
                      label: 'الإشعارات الجديدة',
                      value: '3',
                      color: AppTheme.warningColor,
                    ),
                    Consumer<NotificationsProvider>(
                      builder: (context, notifProvider, _) {
                        return _buildStatCard(
                          icon: Icons.check_circle,
                          label: 'نسبة الأداء',
                          value: '98%',
                          color: AppTheme.accentColor,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// أحدث الإشعارات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أحدث الإشعارات',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/notifications');
                      },
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<NotificationsProvider>(
                  builder: (context, notifProvider, _) {
                    if (notifProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (notifProvider.notifications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 48,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'لا توجد إشعارات',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifProvider.notifications.take(5).length,
                      itemBuilder: (context, index) {
                        final notification = notifProvider.notifications[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(notification.colorValue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(notification.iconData),
                              ),
                            ),
                            title: Text(notification.title),
                            subtitle: Text(
                              notification.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: !notification.isRead
                                ? Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                /// زر إجراء سريع
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/devices');
                    },
                    icon: const Icon(Icons.developer_board),
                    label: const Text('إدارة الأجهزة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arabic',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
