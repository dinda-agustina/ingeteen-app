import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _permissionRequestedKey =
      'notification_permission_requested';

  static Future<void> requestPermissionOnFirstLaunch() async {
    // Permintaan ini hanya ditujukan untuk Android.
    if (!Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();

    // Jangan tampilkan permintaan izin berulang kali.
    final alreadyRequested =
        prefs.getBool(_permissionRequestedKey) ?? false;

    if (alreadyRequested) return;

    // Inisialisasi plugin notifikasi.
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Meminta izin notifikasi melalui sistem Android.
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // Simpan status bahwa permintaan izin sudah pernah ditampilkan.
    await prefs.setBool(_permissionRequestedKey, true);
  }
}