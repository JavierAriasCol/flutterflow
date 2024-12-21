import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TikTok extends StatefulWidget {
  final String videoUrl;

  const TikTok({
    super.key,
    required this.videoUrl,
  });

  @override
  State<TikTok> createState() => _TikTokState();
}

class _TikTokState extends State<TikTok> {
  late VideoPlayerController controller;
  bool _isPlaying = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(
      widget.videoUrl/*,
      httpHeaders: {
        'Cache-Control': 'max-age=432000',
        'Connection': 'keep-alive',
      },*/
    )
      ..initialize().then((_) {
        if (mounted && _isVisible) {
          setState(() => _isPlaying = true);
          controller.play();
        }
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!mounted) return;    
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? controller.play() : controller.pause();
    });
}

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    
    final isVisibleEnough = info.visibleFraction >= 0.5;
    
    if (isVisibleEnough != _isVisible) {
      setState(() {
        _isVisible = isVisibleEnough;
        if (!isVisibleEnough && _isPlaying) {
          _isPlaying = false;
          controller.pause();
        } else if (isVisibleEnough && !_isPlaying) {
          _isPlaying = true;
          controller.play();
        }
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return VisibilityDetector(
    key: Key(widget.videoUrl),
    onVisibilityChanged: _onVisibilityChanged,
    child: GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Player con Loading
          _buildMainContent(),
        
          // Play/Pause Button
          _buildPlayPauseButton(),
          
          // Progress Bar
          _buildProgressBar(),
        ],
      ),
    ),
  );
}

Widget _buildMainContent() {
  return SizedBox.expand(
    child: controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          )
        : const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              color: Colors.white,
            ),
          ),
  );
}

Widget _buildPlayPauseButton() {
  if (!controller.value.isInitialized) return const SizedBox.shrink();
  
  return Positioned(
    bottom: 10,
    right: 15,
    child: AnimatedOpacity(
      opacity: !_isPlaying ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: const Icon(
        Icons.play_arrow,
        size: 30,
        color: Colors.white60,
      ),
    ),
  );
}

Widget _buildProgressBar() {
  if (!controller.value.isInitialized) return const SizedBox.shrink();
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: Colors.red.shade700,
        bufferedColor: Colors.white70,
        backgroundColor: Colors.grey,
      ),
    ),
  );
}
}