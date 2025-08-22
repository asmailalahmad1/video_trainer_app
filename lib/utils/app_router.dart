// filename: lib/utils/app_router.dart

import 'package:flutter/material.dart'; // ستحتاج هذا الـ import للصفحات المؤقتة
import 'package:go_router/go_router.dart';
import 'package:video_trainer_app/auth/auth_gate.dart';
import 'package:video_trainer_app/auth/login_page.dart';
import 'package:video_trainer_app/pages/daily_review_page.dart';
import 'package:video_trainer_app/pages/settings_page.dart';
import 'package:video_trainer_app/pages/stats_page.dart';
import 'package:video_trainer_app/pages/video_details_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    // لجعل التطبيق يبدأ من صفحة تسجيل الدخول دائمًا
    // وتجنب الوميض عند التحقق من حالة المصادقة
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const LoginPage(), // افترض أن لديك صفحة LoginPage
      ),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const AuthGate(), // The gate handles auth state
      ),
      GoRoute(
        path: '/video/:id',
        builder: (context, state) {
          final videoIdString = state.pathParameters['id'];
          // التحقق من أن الـ ID ليس فارغًا ومحاولة تحويله
          if (videoIdString != null) {
            final videoId = int.tryParse(videoIdString);
            if (videoId != null) {
              // ✅ التحويل تم بنجاح
              return VideoDetailsPage(videoId: videoId);
            }
          }
          // في حالة وجود خطأ في الرابط، عرض صفحة خطأ
          return const Scaffold(
            body: Center(
              child: Text('خطأ: الرابط غير صالح أو رقم الفيديو غير صحيح'),
            ),
          );
        },
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) => const DailyReviewPage(),
      ),
      GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

// يمكنك إبقاء هذه الصفحات المؤقتة هنا أو نقلها إلى مجلد pages
// سأفترض أنك قمت بنقلها
// مثال: import 'package:video_trainer_app/pages/daily_review_page.dart';
