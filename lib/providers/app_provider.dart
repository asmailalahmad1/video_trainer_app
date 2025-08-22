// filename: lib/providers/app_provider.dart

import 'package:flutter/material.dart';
import 'package:video_trainer_app/api/supabase_service.dart';
import 'package:video_trainer_app/models/app_profile.dart';
import 'package:video_trainer_app/models/note.dart';
import 'package:video_trainer_app/models/video.dart';

class AppProvider extends ChangeNotifier {
  final SupabaseService _service;

  AppProvider(this._service) {
    // تحقق مما إذا كان المستخدم قد قام بتسجيل الدخول قبل جلب البيانات
    if (_service.currentUserId != null) {
      fetchInitialData();
    }
  }

  // --- State Variables ---
  bool _isLoading = false;
  AppProfile? _profile;
  List<Video> _videos = [];
  List<Video> _dailyReviews = [];
  String _currentFilter = 'الكل';

  // --- Getters ---
  bool get isLoading => _isLoading;
  AppProfile? get profile => _profile;
  List<Video> get videos => _videos;
  List<Video> get dailyReviews => _dailyReviews;
  String get currentFilter => _currentFilter;
  // اختصار لفترات المراجعة للوصول السهل إليها
  List<int> get srsIntervals => _profile?.srsIntervals ?? [1, 3, 7, 14, 30];

  // --- Private Helper ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Public Methods ---

  /// يتم استدعاؤه عند تسجيل الدخول بنجاح
  void onLogin() {
    fetchInitialData();
  }

  /// يتم استدعاؤه عند تسجيل الخروج لتنظيف الحالة
  void onLogout() {
    _profile = null;
    _videos.clear();
    _dailyReviews.clear();
    _currentFilter = 'الكل';
    notifyListeners();
  }

  /// دالة مركزية لتسجيل الخروج
  Future<void> signOut() async {
    await _service.signOut();
    onLogout();
  }

  /// جلب البيانات الأولية عند بدء تشغيل التطبيق
  Future<void> fetchInitialData() async {
    _setLoading(true);
    await Future.wait([fetchProfile(), fetchVideos(), fetchDailyReviews()]);
    _setLoading(false);
  }

  /// جلب فيديو واحد عن طريق الـ ID (مفيد لصفحة التفاصيل)
  Future<Video?> fetchVideoById(int videoId) async {
    return await _service.fetchVideoById(videoId);
  }

  // --- Profile Management ---
  Future<void> fetchProfile() async {
    _profile = await _service.fetchProfile();
    notifyListeners();
  }

  Future<void> updateSrsIntervals(List<int> intervals) async {
    if (_profile == null) return;
    _setLoading(true);
    await _service.updateSrsIntervals(intervals);
    await fetchProfile();
    _setLoading(false);
  }

  // --- Video Management ---
  Future<void> fetchVideos({String? filter}) async {
    _setLoading(true);
    if (filter != null) {
      _currentFilter = filter;
    }
    _videos = await _service.fetchVideos(filter: _currentFilter);
    _setLoading(false);
  }

  Future<void> addVideo(String title, String url, String category) async {
    _setLoading(true);
    await _service.addVideo(title, url, category);
    await fetchVideos(filter: _currentFilter);
  }

  Future<void> deleteVideo(int videoId) async {
    await _service.deleteVideo(videoId);
    _videos.removeWhere((v) => v.id == videoId);
    _dailyReviews.removeWhere((v) => v.id == videoId);
    notifyListeners();
  }

  // --- Review (SRS) Management ---
  Future<void> fetchDailyReviews() async {
    _setLoading(true);
    _dailyReviews = await _service.fetchDailyReviews();
    _setLoading(false);
  }

  Future<void> addToReviewPlan(int videoId) async {
    await _service.addToReviewPlan(videoId);
    await Future.wait([
      fetchVideos(filter: _currentFilter),
      fetchDailyReviews(),
    ]);
  }

  Future<void> markReviewAsDone(int videoId) async {
    if (_profile == null) return;
    await _service.markReviewAsDone(videoId, srsIntervals);
    _dailyReviews.removeWhere((v) => v.id == videoId);
    notifyListeners();
    await fetchVideos(filter: _currentFilter);
  }

  Future<void> postponeReview(int videoId) async {
    await _service.postponeReview(videoId);
    _dailyReviews.removeWhere((v) => v.id == videoId);
    notifyListeners();
  }

  // --- Notes Management ---
  Future<List<Note>> getNotesForVideo(int videoId) {
    return _service.fetchNotesForVideo(videoId);
  }

  Future<void> addNote(int videoId, String content, String type) async {
    await _service.addNote(videoId, content, type);
  }

  // --- Statistics ---
  Future<Map<String, dynamic>> getStats() {
    return _service.fetchStats();
  }
}
