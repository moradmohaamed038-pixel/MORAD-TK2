/// screens/settings_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// قسم حساب المستخدم
              Text(
                'حسابك',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    final user = userProvider.currentUser;
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  (user?.displayName ?? 'M').characters.first.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.displayName ?? 'المستخدم',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email ?? 'بدون بريد',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.roleDisplayName ?? 'عارض',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Arabic',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/profile');
                              },
                              child: const Text('تعديل الملف الشخصي'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              /// قسم الإشعارات والخصوصية
              Text(
                'الإشعارات والخصوصية',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_active),
                      title: const Text('تفعيل الإشعارات', style: TextStyle(fontFamily: 'Arabic')),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('سيتم تطبيق التغييرات قريباً')),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('إشعارات البريد الإلكتروني', style: TextStyle(fontFamily: 'Arabic')),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('خصوصية محسّنة', style: TextStyle(fontFamily: 'Arabic')),
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// قسم التطبيق
              Text(
                'حول التطبيق',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('الإصدار', style: TextStyle(fontFamily: 'Arabic')),
                      trailing: const Text('1.0.0'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('سياسة الخصوصية', style: TextStyle(fontFamily: 'Arabic')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // عرض سياسة الخصوصية
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('شروط الاستخدام', style: TextStyle(fontFamily: 'Arabic')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // عرض شروط الاستخدام
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('الدعم الفني', style: TextStyle(fontFamily: 'Arabic')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // الاتصال بالدعم
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// زر تسجيل الخروج
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Arabic')),
                        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟', style: TextStyle(fontFamily: 'Arabic')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _authService.signOut();
                            },
                            child: const Text('تسجيل خروج'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('تسجيل الخروج'),
                ),
              ),
              const SizedBox(height: 16),

              /// زر حذف الحساب
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى الاتصال بالدعم الفني لحذف الحساب')),
                    );
                  },
                  child: const Text('حذف الحساب', style: TextStyle(fontFamily: 'Arabic')),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
