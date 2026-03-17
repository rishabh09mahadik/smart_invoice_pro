import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> showNotification({
    required String title,
    required String body,
    bool playSound = true,
  }) async {
    // Show Overlay
    showSimpleNotification(
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(body, style: const TextStyle(color: Colors.white)),
      background: const Color(0xFF0F9D58), // AppTheme.primaryColor
      duration: const Duration(seconds: 4),
      slideDismissDirection: DismissDirection.up,
    );

    // Play Sound
    if (playSound) {
      try {
        // Note: Ensure you have a 'notification.mp3' in assets or use a URL
        // For now, we'll use a default system sound or a URL if assets aren't set up
        // Using a short beep sound from a public URL for demonstration
        await _audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    }
  }
}
