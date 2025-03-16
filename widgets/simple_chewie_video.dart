// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!
import '/flutter_flow/flutter_flow_util.dart' show routeObserver;
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

Set<VideoPlayerController> _videoPlayers = {};

class SimpleChewieVideo extends StatefulWidget {
  const SimpleChewieVideo({
    super.key,
    this.width,
    this.height,
    required this.videoguid,
    required this.videoUrl,
    this.borderVideo = 8,
    this.showControls = true,
    this.autoPlay = true,
    this.allowFullScreen = true,
    this.allowMuting = true,
    this.allowPlaybackSpeed = true,
    this.showOptions = true,
    this.hideControlsTimer = 4,
    this.subtitlesUrl,
    this.subtitleFontSize,
    this.subtitleBgColor,
    this.subtitleFontColor,
    this.pauseOnNavigate = true,
  });

  final double? width;
  final double? height;
  final String videoguid;
  final String videoUrl;
  final double borderVideo;
  final bool showControls;
  final bool autoPlay;
  final bool allowFullScreen;
  final bool allowMuting;
  final bool allowPlaybackSpeed;
  final bool showOptions;
  final int hideControlsTimer;
  final List<String>? subtitlesUrl;
  final String? subtitleFontSize;
  final Color? subtitleBgColor;
  final Color? subtitleFontColor;
  final bool pauseOnNavigate;

  @override
  State<SimpleChewieVideo> createState() => _SimpleChewieVideoState();
}

class _SimpleChewieVideoState extends State<SimpleChewieVideo> 
    with RouteAware {
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  Future<void>? _initializeFuture;
  bool subscribedRoute = false;
  bool _hasStarted = false;
  bool _isFullScreen = false;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  @override
  void dispose() {
    if (subscribedRoute) {
      routeObserver.unsubscribe(this);
    }
    _disposeCurrentPlayer();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimpleChewieVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoguid != widget.videoguid) {
      _disposeCurrentPlayer();
      _initializePlayer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.pauseOnNavigate && ModalRoute.of(context) is PageRoute) {
      subscribedRoute = true;
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void didPushNext() {
    if (widget.pauseOnNavigate) {
      videoController?.pause();
    }
  }

  void _disposeCurrentPlayer() {
    _videoPlayers.remove(videoController);
    videoController?.dispose();
    chewieController?.dispose();
  }

  void _initializePlayer() /*async*/ {
    videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true);
    _initializeFuture = videoController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoController!,
      autoInitialize: true,
      draggableProgressBar: true,
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      autoPlay: widget.autoPlay,
      looping: true,
      showControls: widget.showControls,
      allowFullScreen: widget.allowFullScreen,
      allowPlaybackSpeedChanging: widget.allowPlaybackSpeed,
      // hideControlsTimer: widget.hideControlsTimer,
    );
  }
  
  _videoPlayers.add(videoController);
    _videoPlayerController!.addListener(() {
      // Stop all other players when one video is playing.
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayers.forEach((otherPlayer) {
          if (otherPlayer != _videoPlayerController &&
              otherPlayer.value.isPlaying &&
              mounted) {
            setState(() {
              otherPlayer.pause();
            });
          }
        });
      }
    });
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}