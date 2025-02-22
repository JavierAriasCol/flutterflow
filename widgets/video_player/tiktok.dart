import 'package:flutter/material.dart';
import 'package:toktik/presentation/widgets/video/video_progress_bar.dart';
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  Future<void> loadVideo() async {
    controller = VideoPlayerController.network(widget.videoUrl)
    ..setLooping(true);
    // Inicializamos el controlador
    await controller.initialize();
    
    // Una vez inicializado, actualizamos el estado
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: _onVisibilityChanged,
      child: Stack(
        children: [
          // Si el video está inicializado, mostramos el player
          if (_isInitialized)
            VideoPlayer(controller)
          // Mientras se inicializa, mostramos el indicador
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1),
            ),
          
          // Resto de tu UI (gradientes, botones, etc)
          ProgressBar(controller: controller),
        ],
      ),
    );
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}