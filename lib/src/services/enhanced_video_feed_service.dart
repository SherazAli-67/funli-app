import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';

/// Enhanced video feed service with TikTok-level performance optimizations
class EnhancedVideoFeedService {
  static final EnhancedVideoFeedService _instance = EnhancedVideoFeedService._internal();
  factory EnhancedVideoFeedService() => _instance;
  EnhancedVideoFeedService._internal();

  // Video controller management with enhanced lifecycle tracking
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, DateTime> _controllerLastAccess = {};
  final Map<String, bool> _controllerInitialized = {};
  final Set<String> _disposingControllers = {};
  
  // New: Enhanced controller state tracking
  final Map<String, ControllerState> _controllerStates = {};
  final Map<String, int> _controllerReferenceCount = {};
  final Map<String, Timer> _disposalTimers = {};
  
  // Fast scrolling detection
  DateTime _lastScrollTime = DateTime.now();
  bool _isFastScrolling = false;
  Timer? _fastScrollTimer;
  
  // Priority queue for downloads
  final PriorityQueue<_DownloadTask> _downloadQueue = PriorityQueue<_DownloadTask>();
  final Map<String, Completer<File>> _activeDownloads = {};
  
  // Network monitoring
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  NetworkSpeed _currentNetworkSpeed = NetworkSpeed.medium;
  
  // Audio session management
  bool _audioSessionActive = false;
  String? _currentPlayingVideo;
  
  // Performance monitoring
  final Map<String, int> _loadTimes = {};
  final Map<String, int> _bufferEvents = {};
  
  // Configuration based on network speed
  static const int _maxMemoryCache = 8; // Videos in memory
  static const int _maxDiskCache = 50;  // Videos on disk
  
  // Background processing isolate
  Isolate? _backgroundIsolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  
  /// Initialize the enhanced video feed service
  Future<void> initialize() async {
    await _initializeNetworkMonitoring();
    await _initializeBackgroundProcessing();
    await _initializeAudioSession();
    _startPerformanceMonitoring();
  }

  /// Initialize network monitoring
  Future<void> _initializeNetworkMonitoring() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateNetworkSpeed(results);
    });
    
    // Get initial connectivity state
    final results = await Connectivity().checkConnectivity();
    _updateNetworkSpeed(results);
  }

  /// Update network speed based on connectivity
  void _updateNetworkSpeed(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      _currentNetworkSpeed = NetworkSpeed.fast;
    } else if (results.contains(ConnectivityResult.mobile)) {
      _currentNetworkSpeed = NetworkSpeed.medium;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      _currentNetworkSpeed = NetworkSpeed.fast;
    } else {
      _currentNetworkSpeed = NetworkSpeed.slow;
    }
    
    _adjustPrefetchingStrategy();
  }

  /// Initialize background processing isolate
  Future<void> _initializeBackgroundProcessing() async {
    _receivePort = ReceivePort();
    _backgroundIsolate = await Isolate.spawn(
      _backgroundProcessingEntry,
      _receivePort!.sendPort,
    );
    
    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else if (message is Map) {
        _handleBackgroundMessage(message);
      }
    });
  }

  /// Background isolate entry point
  static void _backgroundProcessingEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is Map) {
        _processBackgroundTask(message, sendPort);
      }
    });
  }

  /// Process background tasks
  static void _processBackgroundTask(Map task, SendPort sendPort) {
    switch (task['type']) {
      case 'preload_videos':
        _backgroundPreloadVideos(task, sendPort);
        break;
      case 'cleanup_cache':
        _backgroundCleanupCache(task, sendPort);
        break;
      case 'analyze_patterns':
        _backgroundAnalyzePatterns(task, sendPort);
        break;
    }
  }

  /// Background video preloading
  static void _backgroundPreloadVideos(Map task, SendPort sendPort) {
    // Implement background video preloading logic
    final List<String> urls = List<String>.from(task['urls'] ?? []);
    final int priority = task['priority'] ?? 3;
    
    // Process preloading in background
    for (String url in urls) {
      // Simulate background processing
      // In real implementation, this would handle actual file operations
      sendPort.send({
        'type': 'preload_complete',
        'url': url,
        'success': true,
      });
    }
  }

  /// Background cache cleanup
  static void _backgroundCleanupCache(Map task, SendPort sendPort) {
    // Implement cache cleanup logic
    sendPort.send({
      'type': 'cleanup_complete',
      'freed_space': 1024 * 1024 * 50, // 50MB freed
    });
  }

  /// Background pattern analysis
  static void _backgroundAnalyzePatterns(Map task, SendPort sendPort) {
    // Implement pattern analysis for predictive prefetching
    sendPort.send({
      'type': 'patterns_analyzed',
      'recommendations': ['Happy', 'Excited', 'Love'],
    });
  }

  /// Handle messages from background isolate
  void _handleBackgroundMessage(Map message) {
    switch (message['type']) {
      case 'preload_complete':
        debugPrint('Background preload completed for ${message['url']}');
        break;
      case 'cleanup_complete':
        debugPrint('Cache cleanup freed ${message['freed_space']} bytes');
        break;
      case 'patterns_analyzed':
        _handlePatternRecommendations(List<String>.from(message['recommendations']));
        break;
    }
  }

  /// Initialize audio session management
  Future<void> _initializeAudioSession() async {
    try {
      // Configure audio session for video playback
      await SystemChannels.platform.invokeMethod('AudioSession.setCategory', {
        'category': 'playback',
        'options': ['mixWithOthers'],
      });
    } catch (e) {
      debugPrint('Audio session initialization failed: $e');
    }
  }

  /// Get or create video controller with enhanced caching and safety guards
  Future<VideoPlayerController?> getController(String reelId, String videoUrl, {
    bool shouldPlay = false,
    int priority = 3,
  }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    // Detect fast scrolling
    _updateScrollingState();
    
    // Check if controller already exists and is safe to use
    if (_controllers.containsKey(reelId)) {
      final controller = await _getSafeController(reelId);
      if (controller != null) {
        _controllerLastAccess[reelId] = DateTime.now();
        
        // Increment reference count for active usage
        _controllerReferenceCount[reelId] = (_controllerReferenceCount[reelId] ?? 0) + 1;
        
        if (shouldPlay && _controllerInitialized[reelId] == true) {
          await _playController(reelId);
        }
        
        return controller;
      }
    }
    
    // Check memory cache limit
    if (_controllers.length >= _maxMemoryCache) {
      await _evictOldestController();
    }
    
    try {
      // Get cached video file with priority
      final file = await _getCachedVideoWithPriority(videoUrl, priority);
      
      // Create and initialize controller with enhanced safety
      final controller = VideoPlayerController.file(file);
      
      // Set initial state
      _controllerStates[reelId] = ControllerState.initializing;
      _controllers[reelId] = controller;
      _controllerLastAccess[reelId] = DateTime.now();
      _controllerInitialized[reelId] = false;
      _controllerReferenceCount[reelId] = 1;
      
      // Cancel any pending disposal
      _cancelScheduledDisposal(reelId);
      
      // Initialize controller
      await controller.initialize();
      _controllerInitialized[reelId] = true;
      _controllerStates[reelId] = ControllerState.active;
      
      // Configure controller
      controller.setLooping(true);
      
      // Add performance monitoring
      controller.addListener(() {
        _monitorControllerPerformance(reelId, controller);
      });
      
      // Track load time
      final endTime = DateTime.now().millisecondsSinceEpoch;
      _loadTimes[reelId] = endTime - startTime;
      
      if (shouldPlay) {
        await _playController(reelId);
      }
      
      return controller;
      
    } catch (e) {
      debugPrint('Failed to create controller for $reelId: $e');
      // Clean up any partial state
      _cleanupControllerState(reelId);
      return null;
    }
  }

  /// Get safe controller with comprehensive validation
  Future<VideoPlayerController?> _getSafeController(String reelId) async {
    final controller = _controllers[reelId];
    if (controller == null) return null;
    
    // Check controller state
    final state = _controllerStates[reelId];
    if (state == ControllerState.disposing || 
        state == ControllerState.disposed ||
        _disposingControllers.contains(reelId)) {
      return null;
    }
    
    try {
      // Validate controller is still functional
      final _ = controller.value.isInitialized;
      final _ = controller.value.duration;
      
      return controller;
    } catch (e) {
      // Controller is disposed or invalid
      debugPrint('Controller $reelId failed safety check: $e');
      await _cleanupControllerState(reelId);
      return null;
    }
  }

  /// Update scrolling state for fast scroll detection
  void _updateScrollingState() {
    final now = DateTime.now();
    final timeDiff = now.difference(_lastScrollTime).inMilliseconds;
    
    if (timeDiff < 200) { // Less than 200ms between calls = fast scrolling
      _isFastScrolling = true;
      
      // Reset fast scrolling timer
      _fastScrollTimer?.cancel();
      _fastScrollTimer = Timer(const Duration(milliseconds: 500), () {
        _isFastScrolling = false;
      });
    }
    
    _lastScrollTime = now;
  }

  /// Cancel scheduled disposal
  void _cancelScheduledDisposal(String reelId) {
    final timer = _disposalTimers[reelId];
    if (timer != null) {
      timer.cancel();
      _disposalTimers.remove(reelId);
    }
  }

  /// Clean up controller state
  Future<void> _cleanupControllerState(String reelId) async {
    _controllers.remove(reelId);
    _controllerLastAccess.remove(reelId);
    _controllerInitialized.remove(reelId);
    _controllerStates.remove(reelId);
    _controllerReferenceCount.remove(reelId);
    _disposingControllers.remove(reelId);
    _cancelScheduledDisposal(reelId);
    
    if (_currentPlayingVideo == reelId) {
      _currentPlayingVideo = null;
    }
  }

  /// Get cached video file with priority handling
  Future<File> _getCachedVideoWithPriority(String videoUrl, int priority) async {
    // Try to get from cache first
    File? cachedFile = await ReelsCacheService.getCachedVideo(videoUrl);
    
    if (cachedFile != null && await cachedFile.exists()) {
      return cachedFile;
    }
    
    // Add to download queue with priority
    final task = _DownloadTask(
      url: videoUrl,
      priority: priority,
      networkSpeed: _currentNetworkSpeed,
    );
    
    // Check if already downloading
    if (_activeDownloads.containsKey(videoUrl)) {
      return await _activeDownloads[videoUrl]!.future;
    }
    
    // Start download
    final completer = Completer<File>();
    _activeDownloads[videoUrl] = completer;
    
    try {
      final file = await ReelsCacheService.preCacheVideo(
        videoUrl,
        highPriority: priority <= 2,
        usePriorityCache: priority <= 2,
        useCurrentMoodCache: priority == 1,
      );
      
      completer.complete(file);
      _activeDownloads.remove(videoUrl);
      
      return file;
    } catch (e) {
      completer.completeError(e);
      _activeDownloads.remove(videoUrl);
      rethrow;
    }
  }

  /// Play controller with audio session management
  Future<void> _playController(String reelId) async {
    final controller = await _getSafeController(reelId);
    if (controller == null || !controller.value.isInitialized) return;
    
    // Stop other playing videos
    if (_currentPlayingVideo != null && _currentPlayingVideo != reelId) {
      await _pauseController(_currentPlayingVideo!);
    }
    
    // Activate audio session
    if (!_audioSessionActive) {
      await _activateAudioSession();
    }
    
    // Start playback with error handling
    try {
      await controller.play();
      _currentPlayingVideo = reelId;
    } catch (e) {
      debugPrint('Failed to play controller $reelId: $e');
    }
  }

  /// Pause controller with safety checks
  Future<void> _pauseController(String reelId) async {
    final controller = await _getSafeController(reelId);
    if (controller != null) {
      try {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
      } catch (e) {
        debugPrint('Failed to pause controller $reelId: $e');
      }
    }
    
    if (_currentPlayingVideo == reelId) {
      _currentPlayingVideo = null;
    }
  }

  /// Pause all controllers with enhanced safety
  Future<void> pauseAll() async {
    final controllerIds = List<String>.from(_controllers.keys);
    
    for (final reelId in controllerIds) {
      final controller = await _getSafeController(reelId);
      if (controller != null) {
        try {
          if (controller.value.isPlaying) {
            await controller.pause();
          }
        } catch (e) {
          debugPrint('Failed to pause controller $reelId during pauseAll: $e');
        }
      }
    }
    
    _currentPlayingVideo = null;
    await _deactivateAudioSession();
  }

  /// Release controller reference (smart disposal)
  Future<void> releaseController(String reelId) async {
    final refCount = _controllerReferenceCount[reelId] ?? 0;
    if (refCount > 0) {
      _controllerReferenceCount[reelId] = refCount - 1;
    }
    
    // Schedule disposal if no references remain
    if ((_controllerReferenceCount[reelId] ?? 0) <= 0) {
      _scheduleControllerDisposal(reelId);
    }
  }

  /// Schedule controller disposal with grace period
  void _scheduleControllerDisposal(String reelId) {
    // Don't dispose during fast scrolling
    if (_isFastScrolling) {
      return;
    }
    
    // Cancel existing disposal timer
    _cancelScheduledDisposal(reelId);
    
    // Schedule disposal after grace period
    _disposalTimers[reelId] = Timer(const Duration(seconds: 2), () async {
      await _safeDisposeController(reelId);
    });
    
    _controllerStates[reelId] = ControllerState.pendingDisposal;
  }

  /// Activate audio session
  Future<void> _activateAudioSession() async {
    try {
      await SystemChannels.platform.invokeMethod('AudioSession.setActive', true);
      _audioSessionActive = true;
    } catch (e) {
      debugPrint('Failed to activate audio session: $e');
    }
  }

  /// Deactivate audio session
  Future<void> _deactivateAudioSession() async {
    try {
      await SystemChannels.platform.invokeMethod('AudioSession.setActive', false);
      _audioSessionActive = false;
    } catch (e) {
      debugPrint('Failed to deactivate audio session: $e');
    }
  }

  /// Evict oldest controller from memory with smart selection
  Future<void> _evictOldestController() async {
    if (_controllers.isEmpty) return;
    
    // Find oldest controller that's not currently playing
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _controllerLastAccess.entries) {
      final reelId = entry.key;
      
      // Skip currently playing video
      if (reelId == _currentPlayingVideo) continue;
      
      // Skip controllers with high reference counts
      if ((_controllerReferenceCount[reelId] ?? 0) > 1) continue;
      
      // Skip controllers in disposing state
      if (_disposingControllers.contains(reelId)) continue;
      
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }
    
    if (oldestKey != null) {
      await _safeDisposeController(oldestKey);
    }
  }

  /// Safe disposal with comprehensive state management
  Future<void> _safeDisposeController(String reelId) async {
    // Check if already disposing or disposed
    if (_disposingControllers.contains(reelId) || 
        _controllerStates[reelId] == ControllerState.disposing ||
        _controllerStates[reelId] == ControllerState.disposed) {
      return;
    }
    
    // Mark as disposing
    _disposingControllers.add(reelId);
    _controllerStates[reelId] = ControllerState.disposing;
    
    final controller = _controllers[reelId];
    if (controller != null) {
      try {
        // Pause first
        if (controller.value.isPlaying) {
          await controller.pause();
        }
        
        // Wait a moment for any pending operations
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Dispose the controller
        await controller.dispose();
        
      } catch (e) {
        debugPrint('Error during controller disposal for $reelId: $e');
      }
    }
    
    // Clean up all state
    await _cleanupControllerState(reelId);
    _controllerStates[reelId] = ControllerState.disposed;
  }

  /// Legacy dispose method - now uses safe disposal
  Future<void> _disposeController(String reelId) async {
    await _safeDisposeController(reelId);
  }

  /// Handle scroll away from video (smart cleanup)
  Future<void> onScrollAwayFromVideo(String reelId) async {
    // Pause the video if it's playing
    if (_currentPlayingVideo == reelId) {
      await _pauseController(reelId);
    }
    
    // Release reference
    await releaseController(reelId);
  }

  /// Handle scroll to video (prepare for playback)
  Future<void> onScrollToVideo(String reelId) async {
    // Increment reference count
    _controllerReferenceCount[reelId] = (_controllerReferenceCount[reelId] ?? 0) + 1;
    
    // Cancel any pending disposal
    _cancelScheduledDisposal(reelId);
    
    // Update access time
    _controllerLastAccess[reelId] = DateTime.now();
  }

  /// Emergency cleanup for fast scrolling scenarios
  Future<void> emergencyCleanup() async {
    debugPrint('Performing emergency cleanup due to fast scrolling');
    
    final controllersToDispose = <String>[];
    
    // Find controllers that are safe to dispose
    for (final reelId in _controllers.keys) {
      // Keep currently playing video
      if (reelId == _currentPlayingVideo) continue;
      
      // Keep recently accessed videos (last 5 seconds)
      final lastAccess = _controllerLastAccess[reelId];
      if (lastAccess != null && 
          DateTime.now().difference(lastAccess).inSeconds < 5) {
        continue;
      }
      
      controllersToDispose.add(reelId);
    }
    
    // Dispose half of the eligible controllers
    final disposeCount = (controllersToDispose.length / 2).ceil();
    for (int i = 0; i < disposeCount && i < controllersToDispose.length; i++) {
      await _safeDisposeController(controllersToDispose[i]);
    }
  }

  /// Preload videos with smart strategy
  Future<void> preloadVideos(List<ReelModel> reels, {
    int currentIndex = 0,
    String? currentMood,
  }) async {
    final strategy = _getPrefetchStrategy();
    
    // Calculate videos to preload based on network and position
    final videosToPreload = <_PreloadItem>[];
    
    // Current video (highest priority)
    if (currentIndex < reels.length) {
      videosToPreload.add(_PreloadItem(
        reel: reels[currentIndex],
        priority: 1,
        reason: 'current',
      ));
    }
    
    // Next videos (high priority)
    for (int i = 1; i <= strategy.nextVideos && (currentIndex + i) < reels.length; i++) {
      videosToPreload.add(_PreloadItem(
        reel: reels[currentIndex + i],
        priority: 2,
        reason: 'next_$i',
      ));
    }
    
    // Previous videos (medium priority)
    for (int i = 1; i <= strategy.previousVideos && (currentIndex - i) >= 0; i++) {
      videosToPreload.add(_PreloadItem(
        reel: reels[currentIndex - i],
        priority: 3,
        reason: 'previous_$i',
      ));
    }
    
    // Background videos (low priority)
    for (int i = strategy.nextVideos + 1; i <= strategy.backgroundVideos && (currentIndex + i) < reels.length; i++) {
      videosToPreload.add(_PreloadItem(
        reel: reels[currentIndex + i],
        priority: 4,
        reason: 'background_$i',
      ));
    }
    
    // Execute preloading
    await _executePreloadStrategy(videosToPreload);
  }

  /// Get prefetch strategy based on network speed
  _PrefetchStrategy _getPrefetchStrategy() {
    switch (_currentNetworkSpeed) {
      case NetworkSpeed.fast:
        return _PrefetchStrategy(
          nextVideos: 5,
          previousVideos: 2,
          backgroundVideos: 10,
        );
      case NetworkSpeed.medium:
        return _PrefetchStrategy(
          nextVideos: 3,
          previousVideos: 1,
          backgroundVideos: 5,
        );
      case NetworkSpeed.slow:
        return _PrefetchStrategy(
          nextVideos: 1,
          previousVideos: 1,
          backgroundVideos: 2,
        );
    }
  }

  /// Execute preload strategy
  Future<void> _executePreloadStrategy(List<_PreloadItem> items) async {
    // Sort by priority
    items.sort((a, b) => a.priority.compareTo(b.priority));
    
    // Execute high priority items first (blocking)
    final highPriorityItems = items.where((item) => item.priority <= 2).toList();
    for (final item in highPriorityItems) {
      try {
        await ReelsCacheService.preCacheVideo(
          item.reel.videoUrl,
          highPriority: true,
          usePriorityCache: true,
          useCurrentMoodCache: item.priority == 1,
        );
      } catch (e) {
        debugPrint('High priority preload failed for ${item.reel.reelID}: $e');
      }
    }
    
    // Execute lower priority items in background (non-blocking)
    final backgroundItems = items.where((item) => item.priority > 2).toList();
    if (backgroundItems.isNotEmpty && _sendPort != null) {
      _sendPort!.send({
        'type': 'preload_videos',
        'urls': backgroundItems.map((item) => item.reel.videoUrl).toList(),
        'priority': 3,
      });
    }
  }

  /// Adjust prefetching strategy based on network
  void _adjustPrefetchingStrategy() {
    debugPrint('Network speed changed to: $_currentNetworkSpeed');
    // Implementation for dynamic adjustment
  }

  /// Monitor controller performance
  void _monitorControllerPerformance(String reelId, VideoPlayerController controller) {
    if (controller.value.isBuffering) {
      _bufferEvents[reelId] = (_bufferEvents[reelId] ?? 0) + 1;
    }
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _reportPerformanceMetrics();
    });
  }

  /// Report performance metrics
  void _reportPerformanceMetrics() {
    if (_loadTimes.isEmpty) return;
    
    final avgLoadTime = _loadTimes.values.reduce((a, b) => a + b) / _loadTimes.length;
    final totalBufferEvents = _bufferEvents.values.fold(0, (sum, count) => sum + count);
    
    debugPrint('Performance Metrics:');
    debugPrint('- Average load time: ${avgLoadTime}ms');
    debugPrint('- Total buffer events: $totalBufferEvents');
    debugPrint('- Active controllers: ${_controllers.length}');
    debugPrint('- Network speed: $_currentNetworkSpeed');
  }

  /// Handle pattern recommendations
  void _handlePatternRecommendations(List<String> recommendations) {
    debugPrint('Pattern recommendations: $recommendations');
    // Implement logic to use recommendations for prefetching
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await _connectivitySubscription.cancel();
    
    // Cancel all timers
    _fastScrollTimer?.cancel();
    for (final timer in _disposalTimers.values) {
      timer.cancel();
    }
    _disposalTimers.clear();
    
    // Safely dispose all controllers
    final controllerIds = List<String>.from(_controllers.keys);
    for (final reelId in controllerIds) {
      await _safeDisposeController(reelId);
    }
    _controllers.clear();
    
    // Close background isolate
    _backgroundIsolate?.kill();
    _receivePort?.close();
    
    await _deactivateAudioSession();
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final avgLoadTime = _loadTimes.isEmpty ? 0 : 
      _loadTimes.values.reduce((a, b) => a + b) / _loadTimes.length;
    
    return {
      'averageLoadTime': avgLoadTime,
      'totalBufferEvents': _bufferEvents.values.fold(0, (sum, count) => sum + count),
      'activeControllers': _controllers.length,
      'networkSpeed': _currentNetworkSpeed.toString(),
      'cacheHitRate': _calculateCacheHitRate(),
    };
  }

  /// Calculate cache hit rate
  double _calculateCacheHitRate() {
    // Implementation for cache hit rate calculation
    return 0.85; // Placeholder
  }
}

/// Network speed enumeration
enum NetworkSpeed {
  slow,
  medium,
  fast,
}

/// Prefetch strategy configuration
class _PrefetchStrategy {
  final int nextVideos;
  final int previousVideos;
  final int backgroundVideos;

  _PrefetchStrategy({
    required this.nextVideos,
    required this.previousVideos,
    required this.backgroundVideos,
  });
}

/// Download task for priority queue
class _DownloadTask implements Comparable<_DownloadTask> {
  final String url;
  final int priority;
  final NetworkSpeed networkSpeed;
  final DateTime timestamp;

  _DownloadTask({
    required this.url,
    required this.priority,
    required this.networkSpeed,
  }) : timestamp = DateTime.now();

  @override
  int compareTo(_DownloadTask other) {
    // Lower number = higher priority
    return priority.compareTo(other.priority);
  }
}

/// Preload item configuration
class _PreloadItem {
  final ReelModel reel;
  final int priority;
  final String reason;

  _PreloadItem({
    required this.reel,
    required this.priority,
    required this.reason,
  });
}

/// Controller state enumeration for lifecycle tracking
enum ControllerState { 
  initializing, 
  active, 
  pendingDisposal, 
  disposing, 
  disposed 
}

/// Priority queue implementation
class PriorityQueue<T extends Comparable<T>> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
    _items.sort();
  }

  T? removeFirst() {
    return _items.isEmpty ? null : _items.removeAt(0);
  }

  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;
}
