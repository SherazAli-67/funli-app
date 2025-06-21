import 'package:flutter/material.dart';
// import 'package:reels_viewer/reels_viewer.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/models/user_model.dart';

/// A wrapper around the reels_viewer package to implement reels functionality
/// This implementation uses the reels_viewer package to handle video playback
/// and audio management, which should prevent audio leakage issues.
/// NOTE: This is currently disabled as the reels_viewer package is not installed
class ReelsViewerImplementation extends StatefulWidget {
  final List<ReelModel> reels;
  final int initialIndex;
  final Function(int)? onPageChanged;
  final String comingFrom;

  const ReelsViewerImplementation({
    Key? key,
    required this.reels,
    required this.initialIndex,
    this.onPageChanged,
    required this.comingFrom,
  }) : super(key: key);

  @override
  State<ReelsViewerImplementation> createState() => _ReelsViewerImplementationState();
}

class _ReelsViewerImplementationState extends State<ReelsViewerImplementation> {
  // Commented out until reels_viewer package is added
  // late List<ReelViewModel> _reelViewModels;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // _convertReelsToViewModels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Reels Viewer Package Not Installed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please use the UpdatedReelsPage instead',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  /* Commented out until reels_viewer package is added
  /// Convert our app's ReelModel to the ReelViewModel used by the reels_viewer package
  Future<void> _convertReelsToViewModels() async {
    setState(() => _isLoading = true);
    
    _reelViewModels = [];
    
    for (final reel in widget.reels) {
      // Fetch user data for each reel
      UserModel? user = await UserService.getUserByID(userID: reel.userID);
      
      if (user != null) {
        _reelViewModels.add(
          ReelViewModel(
            // Use the video URL from our reel model
            mediaUrl: reel.videoUrl,
            
            // User information
            profileUrl: user.profilePicture ?? 'https://static.thenounproject.com/png/4530368-200.png',
            username: user.userName,
            
            // Reel content
            caption: reel.caption,
            
            // Engagement metrics
            likesCount: 0, // ReelModel doesn't have likes property
            commentsCount: reel.commentsCount,
            
            // Callbacks
            onLike: () {
              // Handle like action
              // This would need to be implemented to update the likes in Firestore
            },
            onCommentTap: () {
              // Handle comment tap
              // This would need to be implemented to show comments UI
            },
            onShareTap: () {
              // Handle share tap
              // This would need to be implemented to show share options
            },
            onMoreTap: () {
              // Handle more options tap
              // This would need to be implemented to show more options
            },
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The ReelsViewer widget from the package
          ReelsViewer(
            reelsList: _reelViewModels,
            appbarTitle: widget.comingFrom,
            onIndexChanged: widget.onPageChanged,
            initialIndex: widget.initialIndex,
            showAppbar: true,
            showLikes: true,
            showComments: true,
            showShare: true,
            showMore: true,
          ),
          
          // Back button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
  */
}
