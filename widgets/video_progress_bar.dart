import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    required this.controller,
    super.key,
  });

  final VideoPlayerController controller;

  static const progressColors = VideoProgressColors(
    playedColor: Color(0xFFC62828),  // Colors.red.shade700
    bufferedColor: Colors.white70,
    backgroundColor: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: VideoProgressIndicator(
        controller,
        allowScrubbing: true,
        colors: progressColors,
      ),
    );
  }
}
