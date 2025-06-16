import 'package:funli_app/src/models/reel_model.dart';

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReelsState extends Equatable {
  const ReelsState({
    this.videos = const [],
    this.isLoading = false,
    this.isPaginating = false,
    this.hasMore = true,
    this.error = '',
    this.currentIndex = 0,
    this.lastDoc,
  });

  final List<ReelModel> videos;
  final bool isLoading;
  final bool isPaginating;
  final bool hasMore;
  final String error;
  final int currentIndex;
  final DocumentSnapshot? lastDoc;

  @override
  List<Object?> get props => [
    videos,
    isLoading,
    isPaginating,
    hasMore,
    error,
    currentIndex,
    lastDoc,
  ];

  ReelsState copyWith({
    List<ReelModel>? videos,
    bool? isLoading,
    bool? isPaginating,
    bool? hasMore,
    String? error,
    int? currentIndex,
    DocumentSnapshot? lastDoc,
  }) {
    return ReelsState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      currentIndex: currentIndex ?? this.currentIndex,
      lastDoc: lastDoc ?? this.lastDoc,
    );
  }

  factory ReelsState.initial() => const ReelsState();
}