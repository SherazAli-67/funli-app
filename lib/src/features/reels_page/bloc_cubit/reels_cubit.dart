import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:funli_app/src/features/reels_page/bloc_cubit/reels_state.dart';

import '../reel_repository.dart';

class ReelsCubit extends Cubit<ReelsState> {
  ReelsCubit(this.repository) : super(ReelsState.initial()) {
    loadInitial();
  }

  final IReelsRepository repository;

  Future<void> loadInitial() async {
    emit(state.copyWith(videos: repository.initialReels, lastDoc: repository.lastDoc));
    _preloadNext();
  }

  Future<void> onPageChanged(int index) async {
    emit(state.copyWith(currentIndex: index));
    _preloadNext();

    if (!state.isPaginating && state.hasMore && index >= state.videos.length - 2) {
      debugPrint("Loading more");
      await _loadMore();
    }
  }

  Future<void> _loadMore() async {
    emit(state.copyWith(isPaginating: true));
    try {
      final more = await repository.fetchMoreVideos();
      emit(state.copyWith(
        videos: [...state.videos, ...more],
        lastDoc: repository.lastDoc,
        isPaginating: false,
        hasMore: more.isNotEmpty,
      ));
    } catch (e) {
      emit(state.copyWith(isPaginating: false, error: e.toString()));
    }
  }

  void _preloadNext() {
    final currentIndex = state.currentIndex;
    final next = state.videos.skip(currentIndex + 1).take(2).toList();
    for (final reel in next) {
      getCachedVideoFile(reel.videoUrl);
    }
  }

  Future<File> getCachedVideoFile(String url) async {
    final cache = DefaultCacheManager();
    final fileInfo = await cache.getFileFromCache(url);
    return fileInfo?.file ?? await cache.getSingleFile(url);
  }
}