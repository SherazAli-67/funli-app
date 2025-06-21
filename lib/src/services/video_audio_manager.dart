import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// A singleton class to manage video audio and playback across the app
/// This ensures only one video plays at a time with proper lifecycle management
class VideoAudioManager {
  // Singleton instance
  static final VideoAudioManager _instance = VideoAudioManager._internal();
  
  // Factory constructor to return the singleton instance
  factory VideoAudioManager() => _instance;
  
  // Private constructor
  VideoAudioManager._internal();
  
  // Map of video ID to controller for proper tracking
  final Map<String, VideoPlayerController> _controllers = {};
  
  // Current active video ID
  String? _activeVideoId;
  
  // Previous active video ID for cleanup
  String? _previousVideoId;
  
  /// Register a controller with the manager
  void registerController(String videoId, VideoPlayerController controller) {
    _controllers[videoId] = controller;
    debugPrint("📹 Registered controller for video: $videoId");
  }
  
  /// Unregister a controller when it's no longer needed
  void unregisterController(String videoId) {
    final controller = _controllers[videoId];
    if (controller != null) {
      // Ensure it's paused and muted before removal
      try {
        controller.pause();
        controller.setVolume(0.0);
      } catch (e) {
        // Controller might already be disposed
      }
    }
    _controllers.remove(videoId);
    debugPrint("📹 Unregistered controller for video: $videoId");
  }
  
  /// Play a specific video and pause all others
  /// This is the main method that ensures only one video plays at a time
  Future<void> playVideo(String videoId) async {
    if (_activeVideoId == videoId) {
      // Already playing this video
      return;
    }
    
    debugPrint("🎬 Playing video: $videoId");
    
    // Store previous video ID for cleanup
    _previousVideoId = _activeVideoId;
    _activeVideoId = videoId;
    
    // First, pause ALL videos except the one we want to play
    await _pauseAllExcept(videoId);
    
    // Then play the requested video
    final controller = _controllers[videoId];
    if (controller != null && controller.value.isInitialized) {
      try {
        await controller.setVolume(1.0);
        await controller.play();
        debugPrint("✅ Started playing video: $videoId");
      } catch (e) {
        debugPrint("❌ Error playing video $videoId: $e");
      }
    }
  }
  
  /// Pause all videos except the specified one
  Future<void> _pauseAllExcept(String? exceptVideoId) async {
    final futures = <Future>[];
    
    for (final entry in _controllers.entries) {
      if (entry.key != exceptVideoId) {
        final controller = entry.value;
        if (controller.value.isInitialized) {
          try {
            // Pause and mute in parallel for efficiency
            futures.add(controller.pause());
            futures.add(controller.setVolume(0.0));
            debugPrint("⏸️ Paused video: ${entry.key}");
          } catch (e) {
            debugPrint("Error pausing video ${entry.key}: $e");
          }
        }
      }
    }
    
    // Wait for all pause operations to complete
    if (futures.isNotEmpty) {
      await Future.wait(futures, eagerError: false);
    }
  }
  
  /// Pause all videos (useful for app lifecycle events)
  Future<void> pauseAll() async {
    debugPrint("⏸️ Pausing all videos");
    _activeVideoId = null;
    await _pauseAllExcept(null);
  }
  
  /// Get the currently active video ID
  String? get activeVideoId => _activeVideoId;
  
  /// Check if a specific video is currently active
  bool isActiveVideo(String videoId) => _activeVideoId == videoId;
  
  /// Clean up a specific video (pause and mute it)
  Future<void> cleanupVideo(String videoId) async {
    final controller = _controllers[videoId];
    if (controller != null && controller.value.isInitialized) {
      try {
        await controller.pause();
        await controller.setVolume(0.0);
        await controller.seekTo(Duration.zero);
        debugPrint("🧹 Cleaned up video: $videoId");
      } catch (e) {
        debugPrint("Error cleaning up video $videoId: $e");
      }
    }
  }
  
  /// Get controller for a specific video ID
  VideoPlayerController? getController(String videoId) {
    return _controllers[videoId];
  }
  
  /// Debug method to print current state
  void debugPrintState() {
    debugPrint("📊 VideoAudioManager State:");
    debugPrint("   Active video: $_activeVideoId");
    debugPrint("   Registered controllers: ${_controllers.keys.toList()}");
  }
}
