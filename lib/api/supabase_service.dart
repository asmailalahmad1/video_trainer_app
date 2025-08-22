// lib/api/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_trainer_app/models/app_profile.dart';
import 'package:video_trainer_app/models/note.dart';
import 'package:video_trainer_app/models/video.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  // --- Auth ---
  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(password: password, email: email);
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(password: password, email: email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // --- Profile ---
  Future<AppProfile?> fetchProfile() async {
    if (currentUserId == null) return null;
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    return response != null ? AppProfile.fromJson(response) : null;
  }

  Future<void> updateSrsIntervals(List<int> intervals) async {
    await _client
        .from('profiles')
        .update({'srs_intervals': intervals})
        .eq('id', currentUserId!);
  }

  // --- Videos ---
  Future<List<Video>> fetchVideos({String filter = 'الكل'}) async {
    var query = _client.from('videos').select().eq('user_id', currentUserId!);
    if (filter != 'الكل') {
      query = query.eq('status', filter);
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List<dynamic>).map((json) => Video.fromJson(json)).toList();
  }

  Future<void> addVideo(String title, String url, String category) async {
    await _client.from('videos').insert({
      'user_id': currentUserId,
      'title': title,
      'url': url,
      'category': category,
      'status': 'مشاهد',
    });
  }

  Future<void> deleteVideo(int videoId) async {
    await _client.from('videos').delete().eq('id', videoId);
  }

  Future<Video?> fetchVideoById(int videoId) async {
    final response = await _client
        .from('videos')
        .select()
        .eq('id', videoId)
        .maybeSingle();
    return response != null ? Video.fromJson(response) : null;
  }

  // --- Notes ---
  Future<List<Note>> fetchNotesForVideo(int videoId) async {
    final data = await _client
        .from('notes')
        .select()
        .eq('video_id', videoId)
        .order('created_at');
    return data.map((json) => Note.fromJson(json)).toList();
  }

  Future<void> addNote(int videoId, String content, String type) async {
    await _client.from('notes').insert({
      'video_id': videoId,
      'user_id': currentUserId,
      'content': content,
      'note_type': type,
    });
  }

  // --- Reviews (SRS) ---
  Future<List<Video>> fetchDailyReviews() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final data = await _client
        .from('reviews')
        .select('*, videos(*)')
        .eq('user_id', currentUserId!)
        .lte('next_review_date', today);

    return data.map((json) => Video.fromJson(json['videos'])).toList();
  }

  Future<void> addToReviewPlan(int videoId) async {
    final nextReviewDate = DateTime.now().add(const Duration(days: 1));
    await _client.from('reviews').insert({
      'video_id': videoId,
      'user_id': currentUserId,
      'next_review_date': nextReviewDate.toIso8601String(),
      'review_count': 0,
    });
    await _client
        .from('videos')
        .update({'status': 'بانتظار المراجعة'})
        .eq('id', videoId);
  }

  Future<void> markReviewAsDone(int videoId, List<int> srsIntervals) async {
    final review = await _client
        .from('reviews')
        .select()
        .eq('video_id', videoId)
        .single();
    int currentCount = review['review_count'] as int;

    int nextIntervalDays;
    if (currentCount < srsIntervals.length) {
      nextIntervalDays = srsIntervals[currentCount];
    } else {
      nextIntervalDays = srsIntervals.last;
    }

    final nextReviewDate = DateTime.now().add(Duration(days: nextIntervalDays));

    await _client
        .from('reviews')
        .update({
          'last_review_date': DateTime.now().toIso8601String(),
          'next_review_date': nextReviewDate.toIso8601String(),
          'review_count': currentCount + 1,
        })
        .eq('video_id', videoId);

    await _client
        .from('videos')
        .update({'status': 'تمت مراجعته'})
        .eq('id', videoId);
  }

  Future<void> postponeReview(int videoId) async {
    final nextReviewDate = DateTime.now().add(const Duration(days: 1));
    await _client
        .from('reviews')
        .update({'next_review_date': nextReviewDate.toIso8601String()})
        .eq('video_id', videoId);
  }

  // --- Stats ---
  Future<Map<String, dynamic>> fetchStats() async {
    return await _client.rpc('get_user_stats');
  }
}
