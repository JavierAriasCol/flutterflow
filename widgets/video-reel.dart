import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoReel extends StatefulWidget {
  const VideoReel({
    super.key,
    this.width,
    this.height,
    required this.videoUrl,
    required this.postId,
    required this.onDoubleTap,
    required this.videoguid,
  });

  final double? width;
  final double? height;
  final String videoUrl;
  final String postId;
  final Future Function(String postId) onDoubleTap;
  final String videoguid;

  @override
  State<VideoReel> createState() => _VideoReelState();
}

class _VideoReelState extends State<VideoReel> {
  VideoPlayerController? controller;
  Future<void>? _initializeFuture;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true);

    // Almacena el Future de inicialización para que FutureBuilder lo gestione
    _initializeFuture = controller!.initialize();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoguid), // Usar videoguid como clave única
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction >= 0.5) {
          // Solo reproducir si no ha comenzado o si estaba pausado
          if (!_hasStarted || controller?.value.isPlaying == false) {
            controller?.play();
            _hasStarted = true;
          }
        } else {
          controller?.pause();
          controller?.seekTo(Duration.zero); // Regresamos a la posición inicial
        }
      },
      child: FutureBuilder(
        future: _initializeFuture,
        builder: (context, snapshot) {
          // Mientras no se complete la inicialización, mostrar indicador
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 1, color: Colors.white));
          }

          return Center(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: GestureDetector(
                // Doble tap para la función personalizada
                onDoubleTap: () => widget.onDoubleTap(widget.postId),

                // Tap simple para alternar reproducción
                onTap: () {
                  if (controller!.value.isPlaying) {
                    controller!.pause();
                  } else {
                    controller!.play();
                  }
                },

                child: Stack(
                  children: [
                    // Video
                    VideoPlayer(controller!),

                    // Indicador de buffering
                    ValueListenableBuilder(
                      valueListenable: controller!,
                      builder: (context, VideoPlayerValue value, child) {
                        if (value.isBuffering) {
                          return const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 1, color: Colors.white),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Ícono de play cuando está pausado
                    Positioned.fill(
                      child: ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: controller!,
                        builder: (context, value, child) {
                          return AnimatedOpacity(
                            opacity: !value.isPlaying ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 100),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}