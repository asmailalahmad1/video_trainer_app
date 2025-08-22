// filename: lib/pages/stats_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_trainer_app/providers/app_provider.dart';
import 'package:video_trainer_app/utils/app_colors.dart';
import 'package:video_trainer_app/widgets/stat_card.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Provider.of<AppProvider>(context, listen: false).getStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('حدث خطأ في جلب الإحصائيات: ${snapshot.error}'),
            );
          }

          final stats = snapshot.data!;
          final totalVideos = stats['total_videos'] ?? 0;
          final totalNotes = stats['total_notes'] ?? 0;
          final totalReviews = stats['total_reviews'] ?? 0;
          final List topCategoriesData = stats['top_categories'] ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              // إعادة تحميل الصفحة عند السحب
              // ignore: invalid_use_of_protected_member
              (context as Element).reassemble();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'الفيديوهات المشاهدة',
                      value: totalVideos.toString(),
                      icon: Icons.video_library,
                    ),
                    StatCard(
                      title: 'الملاحظات المدونة',
                      value: totalNotes.toString(),
                      icon: Icons.note_alt,
                    ),
                    StatCard(
                      title: 'المراجعات المكتملة',
                      value: totalReviews.toString(),
                      icon: Icons.checklist,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (topCategoriesData.isNotEmpty)
                  _buildPieChart(context, topCategoriesData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List categories) {
    return Column(
      children: [
        Text(
          'أكثر التصنيفات مشاهدة',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(categories.length, (i) {
                final category = categories[i];
                final value = (category['count'] as int).toDouble();
                final title = category['category'] as String;
                final color = AppColors
                    .pieChartColors[i % AppColors.pieChartColors.length];
                return PieChartSectionData(
                  color: color,
                  value: value,
                  title: '$title\n($value)',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }
}
