import 'package:equatable/equatable.dart';
import 'package:funli_app/src/models/reel_model.dart';

class UpdatedFeedState extends Equatable {
  final List<ReelModel> videos;
  final bool isLoading;
  final bool isPaginating;
  final bool hasMoreVideos;
  final String? error;
  final int currentVideoIndex;
  final Set<String> preloadedVideoUrls;
  final bool shouldPauseVideo;
  final String loadingSource;

  const UpdatedFeedState({
    required this.videos,
    required this.isLoading,
    required this.isPaginating,
    required this.hasMoreVideos,
    this.error,
    required this.currentVideoIndex,
    required this.preloadedVideoUrls,
    required this.shouldPauseVideo,
    required this.loadingSource,
  });

  factory UpdatedFeedState.initial() => const UpdatedFeedState(
        videos: [],
        isLoading: true,
        isPaginating: false,
        hasMoreVideos: true,
        currentVideoIndex: 0,
        preloadedVideoUrls: {},
        shouldPauseVideo: false,
        loadingSource: 'initial',
      );

  UpdatedFeedState copyWith({
    List<ReelModel>? videos,
    bool? isLoading,
    bool? isPaginating,
    bool? hasMoreVideos,
    String? error,
    int? currentVideoIndex,
    Set<String>? preloadedVideoUrls,
    bool? shouldPauseVideo,
    String? loadingSource,
  }) {
    return UpdatedFeedState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
      error: error ?? this.error,
      currentVideoIndex: currentVideoIndex ?? this.currentVideoIndex,
      preloadedVideoUrls: preloadedVideoUrls ?? this.preloadedVideoUrls,
      shouldPauseVideo: shouldPauseVideo ?? this.shouldPauseVideo,
      loadingSource: loadingSource ?? this.loadingSource,
    );
  }

  @override
  List<Object?> get props => [
        videos,
        isLoading,
        isPaginating,
        hasMoreVideos,
        error,
        currentVideoIndex,
        preloadedVideoUrls,
        shouldPauseVideo,
        loadingSource,
      ];
}
