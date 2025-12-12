// File: lib/utils/toast_helper.dart
import 'package:flutter/material.dart';

class ToastHelper {
  // 1. Thông báo Lỗi (Màu đỏ)
  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.red.shade600, Icons.error_outline);
  }

  // 2. Thông báo Thành công (Màu xanh)
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.green.shade600, Icons.check_circle_outline);
  }

  // 3. Thông báo Cảnh báo (Màu cam)
  static void showWarning(BuildContext context, String message) {
    _showSnackbar(context, message, Colors.orange.shade800, Icons.warning_amber_rounded);
  }

  // Hàm nội bộ để vẽ giao diện Snackbar
  static void _showSnackbar(BuildContext context, String message, Color color, IconData icon) {
    // Xóa các snackbar cũ đang hiện (nếu có) để hiện cái mới ngay
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Kiểu nổi (không dính đáy màn hình)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16), // Cách lề
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}