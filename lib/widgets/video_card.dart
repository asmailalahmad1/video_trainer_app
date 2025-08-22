// filename: lib/widgets/video_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_trainer_app/utils/app_colors.dart';

class VideoCard extends StatelessWidget {
  final Map<String, dynamic> video;

  const VideoCard({super.key, required this.video});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مشاهد':
        return AppColors.statusWatched;
      case 'بانتظار المراجعة':
        return AppColors.statusAwaitingReview;
      case 'تمت مراجعته':
        return AppColors.statusReviewed;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to video details page
          context.go('/video/${video['id']}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video['title'] ?? 'بدون عنوان',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headline,
                ),
              ),
              const SizedBox(height: 8),
              if (video['category'] != null && video['category'].isNotEmpty)
                Text(
                  'التصنيف: ${video['category']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(video['status']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      video['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
