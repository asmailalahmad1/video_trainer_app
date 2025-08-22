// filename: lib/utils/helpers.dart

import 'package:flutter/material.dart';

/// يعرض SnackBar أخضر للنجاح
void showSuccessSnackBar(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green[600]),
  );
}

/// يعرض SnackBar أحمر للخطأ
void showErrorSnackBar(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red[600]),
  );
}
