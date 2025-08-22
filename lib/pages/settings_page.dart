// filename: lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_trainer_app/providers/app_provider.dart'; // ✅ استيراد صحيح

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // لا نحتاج لـ listen: false هنا لأننا نستخدمه داخل دالة onTap فقط
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج'),
            onTap: () async {
              // عرض نافذة تأكيد قبل الخروج
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تأكيد الخروج'),
                  content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'خروج',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              // إذا ضغط المستخدم على "خروج"
              if (confirm == true) {
                await appProvider.signOut();

                // التأكد من أن الـ widget ما زال في الشجرة قبل التعامل معه
                if (context.mounted) {
                  // استخدام go لإعادة التوجيه إلى صفحة تسجيل الدخول
                  context.go('/login');
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('الإشعارات'),
            subtitle: const Text('قيد التطوير'),
            onTap: () {
              // يمكن إضافة رسالة للمستخدم هنا في المستقبل
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('تصدير البيانات'),
            subtitle: const Text('قيد التطوير'),
            onTap: () {
              // يمكن إضافة رسالة للمستخدم هنا في المستقبل
            },
          ),
        ],
      ),
    );
  }
}
