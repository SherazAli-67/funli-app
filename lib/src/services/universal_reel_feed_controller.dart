import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/reel_model.dart';
import '../res/app_constants.dart';
import 'reels_data_sources.dart';

/// Universal controller that manages reel feeds from multiple sources
/// Provides seamless Instagram-like experience across different reel sources
class UniversalReelFeedController {
  final ReelDataSource _dataSource;
  final List<ReelModel> _reels = [];
  final StreamController<List<ReelModel>> _reelsController = StreamController<List<ReelModel>>.broadcast();
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;
  int _currentIndex = 0;
  
  // Performance tracking
  final Map<String, int> _loadTimes = {};
  final Completer<void> _initializationCompleter = Completer<void>();
  
  UniversalReelFeedController(this._dataSource);

  // Public getters
  List<ReelModel> get reels => List.unmodifiable(_reels);
  Stream<List<ReelModel>> get reelsStream => _reelsController.stream;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  int get currentIndex => _currentIndex;
  String get sourceType => _dataSource.sourceType;
  Map<String, dynamic> get sourceContext => _dataSource.context;
  
  /// Initialize the controller with initial reels
  Future<void> initialize({
    List<ReelModel>? initialReels,
    int selectedIndex = 0,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      _currentIndex = selectedIndex;
      _lastDocument = lastDocument;
      
      if (initialReels != null && initialReels.isNotEmpty) {
        _reels.clear();
        _reels.addAll(initialReels);
        _reelsController.add(_reels);
        
        debugPrint('UniversalReelFeedController initialized with ${initialReels.length} initial reels');
        
        // Start preloading more data if we're close to the end
        if (_currentIndex >= _reels.length - 5) {
          _fetchMoreReels();
        }
      } else {
        // No initial reels provided, fetch from source
        await _fetchMoreReels();
      }
      
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
    } catch (e) {
      debugPrint('Error initializing UniversalReelFeedController: $e');
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.completeError(e);
      }
    }
  }
  
  /// Wait for initialization to complete
  Future<void> waitForInitialization() => _initializationCompleter.future;
  
  /// Update current index and trigger preloading if needed
  void updateCurrentIndex(int newIndex) {
    _currentIndex = newIndex;
    
    // Start preloading when user is approaching the end
    if (_hasMoreData && newIndex >= _reels.length - 5) {
      _fetchMoreReels();
    }
    
    debugPrint('Current index updated to: $newIndex, total reels: ${_reels.length}');
  }
  
  /// Fetch more reels from the data source
  Future<void> _fetchMoreReels() async {
    if (_isLoading || !_hasMoreData) return;
    
    _isLoading = true;
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    try {
      debugPrint('Fetching more reels from ${_dataSource.sourceType} source...');
      
      final result = await _dataSource.fetchMoreReels(_lastDocument);
      
      if (result.newReels.isNotEmpty) {
        _reels.addAll(result.newReels);
        _lastDocument = result.lastDocument;
        _hasMoreData = result.hasMore;
        
        // Notify listeners
        _reelsController.add(_reels);
        
        debugPrint('Fetched ${result.newReels.length} more reels. Total: ${_reels.length}');
      } else {
        _hasMoreData = false;
        debugPrint('No more reels available from source');
      }
      
      // Track load time
      final endTime = DateTime.now().millisecondsSinceEpoch;
      _loadTimes[_dataSource.sourceType] = endTime - startTime;
      
    } catch (e) {
      debugPrint('Error fetching more reels: $e');
      _hasMoreData = false;
    } finally {
      _isLoading = false;
    }
  }
  
  /// Manually refresh the feed (pull to refresh)
  Future<void> refreshFeed() async {
    try {
      _isLoading = true;
      _hasMoreData = true;
      _lastDocument = null;
      
      debugPrint('Refreshing feed for ${_dataSource.sourceType} source...');
      
      final result = await _dataSource.fetchMoreReels(null);
      
      _reels.clear();
      if (result.newReels.isNotEmpty) {
        _reels.addAll(result.newReels);
        _lastDocument = result.lastDocument;
        _hasMoreData = result.hasMore;
      }
      
      _reelsController.add(_reels);
      _currentIndex = 0;
      
      debugPrint('Feed refreshed with ${_reels.length} reels');
      
    } catch (e) {
      debugPrint('Error refreshing feed: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  /// Get reel at specific index
  ReelModel? getReelAt(int index) {
    if (index >= 0 && index < _reels.length) {
      return _reels[index];
    }
    return null;
  }
  
  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final avgLoadTime = _loadTimes.isEmpty ? 0 : 
      _loadTimes.values.reduce((a, b) => a + b) / _loadTimes.length;
    
    return {
      'sourceType': _dataSource.sourceType,
      'totalReels': _reels.length,
      'currentIndex': _currentIndex,
      'hasMoreData': _hasMoreData,
      'isLoading': _isLoading,
      'averageLoadTime': avgLoadTime,
      'sourceContext': _dataSource.context,
    };
  }
  
  /// Dispose resources
  void dispose() {
    _reelsController.close();
    debugPrint('UniversalReelFeedController disposed');
  }
}

/// Factory class to create appropriate data sources
class ReelDataSourceFactory {
  static ReelDataSource createDataSource({
    required String comingFrom,
    String? mood,
    String? tag,
    String? userID,
    Map<String, dynamic>? filterContext,
  }) {
    switch (comingFrom) {
      case AppConstants.comingFromMood:
        return MoodReelDataSource(mood: mood ?? 'Happy');
      
      case AppConstants.comingFromHashtag:
        return HashtagReelDataSource(tag: tag ?? '');
      
      case AppConstants.comingFromSearch:
        return SearchReelDataSource(
          filter: filterContext != null ? 
            ReelSearchFilter.fromMap(filterContext) : 
            ReelSearchFilter(),
        );
      
      case AppConstants.comingFromUserProfile:
        return UserProfileReelDataSource(userID: userID ?? '');
      
      case AppConstants.comingFromBookmark:
        return BookmarkReelDataSource(userID: userID ?? '');
      
      default:
        throw ArgumentError('Unknown reel source: $comingFrom');
    }
  }
}

/// Filter class for search-based reels
class ReelSearchFilter {
  final String? selectedMood;
  final String? selectedPopularity;
  final String? location;
  final String? language;
  
  ReelSearchFilter({
    this.selectedMood,
    this.selectedPopularity,
    this.location,
    this.language,
  });
  
  factory ReelSearchFilter.fromMap(Map<String, dynamic> map) {
    return ReelSearchFilter(
      selectedMood: map['selectedMood'],
      selectedPopularity: map['selectedPopularity'],
      location: map['location'],
      language: map['language'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'selectedMood': selectedMood,
      'selectedPopularity': selectedPopularity,
      'location': location,
      'language': language,
    };
  }
}
