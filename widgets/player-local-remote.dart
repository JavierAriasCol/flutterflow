import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class LocalVideoPlayer extends StatefulWidget {
  const LocalVideoPlayer({
    super.key,
    this.width,
    this.height,
    required this.videoPath,
  });

  final double? width;
  final double? height;
  final String videoPath;

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = VideoPlayerController.file(File(widget.videoPath))
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          controller?.play();
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
          child:
              CircularProgressIndicator(strokeWidth: 1, color: Colors.white));
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: VideoPlayer(controller!),
      ),
    );
  }
}