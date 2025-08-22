// filename: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // <-- 1. استيراد Provider
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_trainer_app/api/supabase_service.dart';
import 'package:video_trainer_app/providers/app_provider.dart';
import 'package:video_trainer_app/utils/app_colors.dart';
import 'package:video_trainer_app/utils/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- 2. استيراد Localization

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐️ التعديل الأول: إضافة Provider
    return ChangeNotifierProvider(
      create: (context) => AppProvider(SupabaseService(supabase)),
      child: MaterialApp.router(
        title: 'مدرب الفيديوهات التعليمية',
        theme: ThemeData(
          fontFamily: 'Cairo',
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            background: AppColors.background,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: AppColors.headline,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            iconTheme: IconThemeData(color: AppColors.headline),
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,

        // ⭐️ التعديل الثاني: إضافة دعم اللغة العربية
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', ''), // Arabic
        ],
        locale: const Locale('ar', ''),

        builder: (context, child) {
          // لجعل الواجهة من اليمين لليسار
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}
