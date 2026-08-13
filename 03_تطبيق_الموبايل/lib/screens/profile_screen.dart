/// screens/profile_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../core/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفي الشخصي'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return _isEditing
                  ? TextButton(
                      onPressed: () async {
                        final success = await userProvider.updateCurrentUser(
                          displayName: _nameController.text,
                          phoneNumber: _phoneController.text,
                        );
                        if (success && mounted) {
                          setState(() => _isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
                          );
                        }
                      },
                      child: const Text('حفظ'),
                    )
                  : TextButton(
                      onPressed: () {
                        setState(() => _isEditing = true);
                      },
                      child: const Text('تعديل'),
                    );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // تحديث حقول الإدخال عند تحميل البيانات
          if (!_isEditing && _nameController.text.isEmpty) {
            _nameController.text = user.displayName;
            _phoneController.text = user.phoneNumber ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// صورة الملف الشخصي
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          (user.displayName).characters.first.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ستتمكن من تغيير الصورة قريباً')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                /// بيانات الملف الشخصي
                Text(
                  'البيانات الشخصية',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),

                /// حقل الاسم
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// حقل البريد الإلكتروني (غير قابل للتعديل)
                TextFormField(
                  enabled: false,
                  initialValue: user.email,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// حقل رقم الهاتف
                TextFormField(
                  controller: _phoneController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                /// حقل الدور
                TextFormField(
                  enabled: false,
                  initialValue: user.roleDisplayName,
                  decoration: InputDecoration(
                    labelText: 'الدور',
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                /// قسم الأجهزة المشترك فيها
                Text(
                  'الأجهزة المشترك فيها',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (user.deviceIds.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'لم تُضف أي أجهزة بعد',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: user.deviceIds.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.developer_board),
                          title: Text(user.deviceIds[index]),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                /// قسم معلومات الحساب
                Text(
                  'معلومات الحساب',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('تاريخ الإنشاء', _formatDate(user.createdAt)),
                        const SizedBox(height: 12),
                        _buildInfoRow('آخر تسجيل دخول', user.lastLoginAt != null ? _formatDate(user.lastLoginAt!) : 'لم يسجل بعد'),
                        const SizedBox(height: 12),
                        _buildInfoRow('الحالة', user.isActive ? 'نشط' : 'غير نشط'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
