// filename: lib/models/note.dart

import 'package:flutter/material.dart';

// قائمة بأنواع الملاحظات لتسهيل استخدامها في الواجهة
enum NoteType {
  idea('فكرة', Icons.lightbulb_outline),
  question('سؤال', Icons.help_outline),
  reviewPoint('نقطة للمراجعة', Icons.sync_problem_outlined),
  example('مثال', Icons.format_quote_outlined);

  const NoteType(this.arabicName, this.icon);
  final String arabicName;
  final IconData icon;

  // دالة مساعدة لتحويل النص القادم من قاعدة البيانات إلى Enum
  static NoteType fromString(String typeString) {
    return NoteType.values.firstWhere(
      (e) => e.arabicName == typeString,
      orElse: () => NoteType.idea, // قيمة افتراضية في حال وجود خطأ
    );
  }
}

class Note {
  final int id;
  final int videoId;
  final String userId;
  final String content;
  final NoteType noteType; // نستخدم الـ Enum هنا
  final DateTime createdAt;

  Note({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.content,
    required this.noteType,
    required this.createdAt,
  });

  /// [fromJson]
  /// دالة Factory لإنشاء كائن Note من بيانات JSON (Map)
  /// هذه هي الطريقة التي نحول بها البيانات القادمة من Supabase إلى كائن Dart
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      videoId: json['video_id'] as int,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      // تحويل النص من قاعدة البيانات إلى نوع الملاحظة الصحيح
      noteType: NoteType.fromString(json['note_type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// [toJson]
  /// دالة لتحويل كائن Note إلى بيانات JSON (Map)
  /// مفيدة عند إرسال البيانات إلى Supabase (لإنشاء أو تحديث ملاحظة)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'user_id': userId,
      'content': content,
      'note_type': noteType.arabicName, // نحول الـ Enum إلى نص قبل إرساله
      'created_at': createdAt.toIso8601String(),
    };
  }

  // دالة مساعدة للطباعة أثناء التطوير (Debugging)
  @override
  String toString() {
    return 'Note(id: $id, type: ${noteType.arabicName}, content: "$content")';
  }
}
