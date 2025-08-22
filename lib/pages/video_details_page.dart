// lib/pages/video_details_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_trainer_app/models/note.dart';
import 'package:video_trainer_app/models/video.dart';
import 'package:video_trainer_app/providers/app_provider.dart';
import 'package:video_trainer_app/utils/app_colors.dart';
import 'package:video_trainer_app/utils/helpers.dart';
import 'package:video_trainer_app/widgets/note_card.dart';

class VideoDetailsPage extends StatefulWidget {
  final int videoId;
  const VideoDetailsPage({super.key, required this.videoId});

  @override
  State<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  late Future<Video?> _videoFuture;
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    // جلب الفيديو من القائمة المخبأة أولاً، أو من الشبكة إذا لم يكن موجودًا
    final cachedVideo = provider.videos.firstWhere(
      (v) => v.id == widget.videoId,
      orElse: () => provider.dailyReviews.firstWhere(
        (v) => v.id == widget.videoId,
        orElse: () => null as Video,
      ),
    );

    if (cachedVideo != null) {
      _videoFuture = Future.value(cachedVideo);
    } else {
      // إذا لم يكن الفيديو في الذاكرة، اجلبه من الشبكة
      // هذه الحالة نادرة لكنها مهمة
      _videoFuture = provider.fetchVideoById(widget.videoId);
    }

    _notesFuture = provider.getNotesForVideo(widget.videoId);
  }

  void _showAddNoteDialog(BuildContext context, int videoId) {
    final contentController = TextEditingController();
    NoteType selectedType = NoteType.idea; // القيمة الافتراضية

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إضافة ملاحظة جديدة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<NoteType>(
                      value: selectedType,
                      items: NoteType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(type.icon, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(type.arabicName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'محتوى الملاحظة',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (contentController.text.isNotEmpty) {
                      await Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).addNote(
                        videoId,
                        contentController.text,
                        selectedType.arabicName,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        // إعادة تحميل الملاحظات
                        setState(() {
                          _notesFuture = Provider.of<AppProvider>(
                            context,
                            listen: false,
                          ).getNotesForVideo(widget.videoId);
                        });
                      }
                    }
                  },
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // زر الرجوع يظهر تلقائيًا بفضل GoRouter
        title: const Text('تفاصيل الفيديو'),
      ),
      body: FutureBuilder<Video?>(
        future: _videoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('لم يتم العثور على الفيديو'));
          }
          final video = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildVideoInfoCard(video),
              const SizedBox(height: 24),
              _buildNotesSection(video.id),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoInfoCard(Video video) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(video.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (video.category != null && video.category!.isNotEmpty)
              Text('التصنيف: ${video.category}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (video.url != null && video.url!.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.link),
                    label: const Text('فتح المصدر'),
                    onPressed: () async {
                      final uri = Uri.parse(video.url!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                // لا نعرض الزر إذا كان الفيديو بالفعل في خطة المراجعة
                if (video.status == 'مشاهد')
                  ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).addToReviewPlan(video.id);
                      showSuccessSnackBar(
                        context,
                        message: 'تمت إضافة الفيديو لخطة المراجعة',
                      );
                      // إعادة تحميل البيانات لتحديث الحالة
                      setState(() {
                        _loadData();
                      });
                    },
                    icon: const Icon(Icons.add_task),
                    label: const Text('أضف إلى خطة المراجعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(int videoId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الملاحظات',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: AppColors.primary,
                size: 30,
              ),
              onPressed: () => _showAddNoteDialog(context, videoId),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Note>>(
          future: _notesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('لا توجد ملاحظات بعد. أضف أول ملاحظة!'),
                ),
              );
            }
            final notes = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteCard(note: notes[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
