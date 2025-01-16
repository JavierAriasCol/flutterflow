// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
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
              CircularProgressIndicator(strokeWidth: 0.5, color: Colors.white));
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
              if (value.isBuffering)
                const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 1, color: Colors.white),
                ),
            ],
          );
        },
      ),
    );
  }
}
