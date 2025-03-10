import 'package:flutter/material.dart';
import 'package:toktik/presentation/widgets/video/video_progress_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoReel extends StatefulWidget {
  final String videoPath;

  const VideoReel({
    super.key,
    required this.videoPath,
  });

  @override
  State<VideoReel> createState() => _VideoReelState();
}

class _VideoReelState extends State<VideoReel> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = VideoPlayerController.network(widget.videoPath)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white)
      );
    }

    return VisibilityDetector(
      key: Key(widget.videoPath), // Usar videoPath como identificador único
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction >= 0.8) {
          controller?.play();
        } else {
          controller?.pause();
        }
      },
      child: ValueListenableBuilder(
      valueListenable: controller!,
      builder: (context, VideoPlayerValue value, child) {
        return Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
            ),
            VideoProgressBar(controller: controller!),
            if (value.isBuffering)
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1, 
                  color: Colors.white
                ),
              ),
          ],
        );
      },
    ),
    );
  }
}