import 'package:equatable/equatable.dart';
import 'package:funli_app/src/models/reel_model.dart';

class VideoFeedState extends Equatable {
  const VideoFeedState({
    this.videos = const [],
    this.isLoading = false,
    this.isPaginating = false,
    this.hasMoreVideos = true,
    this.error = '',
    this.currentVideoIndex = 0,
    this.preloadedVideoUrls = const {},
    this.shouldPauseVideo = false
  });

  final List<ReelModel> videos;
  final bool isLoading;
  final bool isPaginating;
  final bool hasMoreVideos;
  final String error;
  final int currentVideoIndex;
  final Set<String> preloadedVideoUrls;
  final bool shouldPauseVideo;
  @override
  List<Object> get props => [
    videos,
    isLoading,
    isPaginating,
    hasMoreVideos,
    error,
    currentVideoIndex,
    preloadedVideoUrls,
    shouldPauseVideo,
  ];

  VideoFeedState copyWith({
    List<ReelModel>? videos,
    bool? isLoading,
    bool? isPaginating,
    bool? hasMoreVideos,
    String? error,
    int? currentVideoIndex,
    Set<String>? preloadedVideoUrls,
    bool? shouldPauseVideo,
  }) {
    return VideoFeedState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
      error: error ?? this.error,
      currentVideoIndex: currentVideoIndex ?? this.currentVideoIndex,
      preloadedVideoUrls: preloadedVideoUrls ?? this.preloadedVideoUrls,
      shouldPauseVideo: shouldPauseVideo ?? this.shouldPauseVideo,
    );
  }

  factory VideoFeedState.initial() => const VideoFeedState();
}
