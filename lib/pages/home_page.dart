// filename: lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_trainer_app/main.dart';
import 'package:video_trainer_app/widgets/video_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO: Implement filter logic based on a variable
  String _currentFilter = 'الكل';

  final _videosStream = supabase
      .from('videos')
      .stream(primaryKey: ['id'])
      .eq('user_id', supabase.auth.currentUser!.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فيديوهاتي التعليمية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30),
            onPressed: () {
              // TODO: Implement add video dialog/page
              _showAddVideoDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _videosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'لم تقم بإضافة أي فيديوهات بعد.\nابدأ بالضغط على علامة +',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final videos = snapshot.data!;
                // TODO: Apply the actual filter logic here
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return VideoCard(video: video);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/review');
              break;
            case 2:
              context.go('/stats');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'مراجعة'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'إحصائيات',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    // A simple placeholder for filter UI
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FilterChip(label: Text('الكل'), onSelected: (val) {}),
          FilterChip(label: Text('المشاهد'), onSelected: (val) {}),
          FilterChip(label: Text('بانتظار المراجعة'), onSelected: (val) {}),
        ],
      ),
    );
  }

  void _showAddVideoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة فيديو جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'العنوان'),
              ),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'الرابط (اختياري)'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'التصنيف'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await supabase.from('videos').insert({
                    'user_id': supabase.auth.currentUser!.id,
                    'title': titleController.text,
                    'url': urlController.text,
                    'category': categoryController.text,
                    'status': 'مشاهد', // Default status
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
}
