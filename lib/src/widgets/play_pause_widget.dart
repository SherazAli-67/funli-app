import 'package:flutter/material.dart';

class PlayPauseWidget extends StatelessWidget {
  const PlayPauseWidget({
    super.key,
    required bool isPlaying,
  }) : _isPlaying = isPlaying;

  final bool _isPlaying;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .5,
      child: AnimatedOpacity(
        opacity: _isPlaying ? 0 : 1,
        duration: const Duration(milliseconds: 500),
        child: Container(
          alignment: Alignment.center,
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 1),
            ),
          ),
          child: _isPlaying
              ? const Icon(Icons.pause, color: Colors.white, size: 40)
              : const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}