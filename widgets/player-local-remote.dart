import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class LocalVideoPlayer extends StatefulWidget {
  const LocalVideoPlayer({
    super.key,
    this.width,
    this.height,
    required this.videoPath,  // Cambiado el nombre para reflejar que solo acepta path local
  });

  final double? width;
  final double? height;
  final String videoPath;

  @override
  State<LocalVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<LocalVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController.addListener(_videoListener);
  }

  void _videoListener() {
    if (_videoPlayerController.value.position ==
        _videoPlayerController.value.duration) {
      setState(() {
        _isPlaying = false;
        _videoPlayerController.seekTo(Duration.zero);
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _playPauseVideo() {
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else {
        if (_videoPlayerController.value.position ==
            _videoPlayerController.value.duration) {
          _videoPlayerController.seekTo(Duration.zero);
        }
        _videoPlayerController.play();
      }
      _isPlaying = _videoPlayerController.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videoPlayerController.value.isInitialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: Platform.isAndroid
                        ? RotatedBox(
                            quarterTurns: -1,
                            child: VideoPlayer(_videoPlayerController),
                          )
                        : VideoPlayer(_videoPlayerController),
                  ),
                ),
                IconButton(
                  iconSize: 150.0,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _playPauseVideo,
                ),
                Positioned(
                  bottom: 10.0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    _videoPlayerController,
                    allowScrubbing: true,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}