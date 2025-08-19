
import 'package:funli_app/src/models/reel_model.dart';

abstract class IVideoFeedRepository {
  /// Fetch the initial batch of video items from Firestore.
  /// In this example, we fetch 2 items.
  Future<List<ReelModel>> fetchVideos({bool isRefresh = false, int limit = 5});

  /// Fetch additional videos for pagination.
  Future<List<ReelModel>> fetchMoreVideos();
}
