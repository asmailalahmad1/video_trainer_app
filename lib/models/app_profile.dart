// filename: lib/models/app_profile.dart

class AppProfile {
  final String id; // This is the user's UUID from Supabase Auth
  final String? username;
  final DateTime updatedAt;
  final List<int> srsIntervals; // قائمة بفترات المراجعة بالأيام

  AppProfile({
    required this.id,
    this.username,
    required this.updatedAt,
    required this.srsIntervals,
  });

  /// [fromJson]
  /// دالة Factory لإنشاء كائن AppProfile من بيانات JSON (Map)
  /// القادمة من جدول `profiles` في Supabase.
  factory AppProfile.fromJson(Map<String, dynamic> json) {
    // Supabase يرسل مصفوفات الأرقام كـ List<dynamic>. يجب تحويلها.
    final intervalsList = (json['srs_intervals'] as List<dynamic>?) ?? [];

    return AppProfile(
      id: json['id'] as String,
      username: json['username'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // تحويل كل عنصر في القائمة إلى int.
      // إذا كانت القائمة فارغة، نستخدم القيمة الافتراضية.
      srsIntervals: intervalsList.isNotEmpty
          ? intervalsList.map((e) => e as int).toList()
          : [1, 3, 7, 14, 30], // قيمة افتراضية احتياطية
    );
  }

  /// [toJson]
  /// دالة لتحويل كائن AppProfile إلى بيانات JSON (Map)
  /// مفيدة عند تحديث بيانات الملف الشخصي في Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'updated_at': updatedAt.toIso8601String(),
      'srs_intervals': srsIntervals,
    };
  }

  /// [copyWith]
  /// دالة مساعدة لإنشاء نسخة من الكائن مع تعديل بعض الحقول.
  /// مفيدة جدًا في إدارة الحالة (State Management).
  AppProfile copyWith({
    String? id,
    String? username,
    DateTime? updatedAt,
    List<int>? srsIntervals,
  }) {
    return AppProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      updatedAt: updatedAt ?? this.updatedAt,
      srsIntervals: srsIntervals ?? this.srsIntervals,
    );
  }

  // دالة مساعدة للطباعة أثناء التطوير (Debugging)
  @override
  String toString() {
    return 'AppProfile(id: $id, username: $username, srsIntervals: $srsIntervals)';
  }
}
