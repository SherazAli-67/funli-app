import 'dart:async';
import 'package:flutter/material.dart';
import 'package:funli_app/src/services/video_audio_manager.dart';

/// A utility class to detect fast scrolling and manage audio accordingly
/// This helps prevent audio leakage when users scroll quickly through videos
class ScrollDetector {
  // Singleton instance
  static final ScrollDetector _instance = ScrollDetector._internal();
  
  // Factory constructor to return the singleton instance
  factory ScrollDetector() => _instance;
  
  // Private constructor
  ScrollDetector._internal();
  
  // Scroll velocity threshold to consider as "fast scrolling"
  static const double _fastScrollThreshold = 500.0;
  
  // Debounce timer for scroll events
  Timer? _scrollDebounceTimer;
  
  // Flag to track if we're currently in fast scroll mode
  bool _isInFastScroll = false;
  
  /// Call this method from a ScrollController's listener
  /// It will detect fast scrolling and mute all videos during fast scrolls
  void handleScrollUpdate(ScrollController scrollController) {
    // Cancel any existing timer
    _scrollDebounceTimer?.cancel();
    
    // Check if this is a fast scroll
    final velocity = scrollController.position.activity?.velocity ?? 0.0;
    final isFastScroll = velocity.abs() > _fastScrollThreshold;
    
    if (isFastScroll && !_isInFastScroll) {
      // We just entered fast scroll mode
      _isInFastScroll = true;
      
      // Mute all videos during fast scrolling
      VideoAudioManager().pauseAll();
    }
    
    // Set a debounce timer to detect when scrolling stops or slows down
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (_isInFastScroll) {
        // We're exiting fast scroll mode
        _isInFastScroll = false;
        
        // The currently visible video will be unmuted by its widget
        // when it becomes visible, so we don't need to do anything here
      }
    });
  }
  
  /// A scroll listener that can be attached to a ScrollController
  /// This is a convenience method to avoid boilerplate in widgets
  ScrollController attachToController(ScrollController controller) {
    controller.addListener(() {
      handleScrollUpdate(controller);
    });
    return controller;
  }
  
  /// Create a new ScrollController with the scroll detector attached
  ScrollController createController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
  }) {
    final controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      debugLabel: debugLabel,
    );
    
    controller.addListener(() {
      handleScrollUpdate(controller);
    });
    
    return controller;
  }
}
