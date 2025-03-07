import 'package:video_player/video_player.dart';
import 'dart:io';

class LocalVideoCompress extends StatefulWidget {
  const LocalVideoCompress({
    super.key,
    this.width,
    this.height,
    required this.videoPath,
    required this.borderVideo,
  });

  final double? width;
  final double? height;
  final String videoPath;
  final double borderVideo;

  @override
  State<LocalVideoCompress> createState() => _LocalVideoCompressState();
}

class _LocalVideoCompressState extends State<LocalVideoCompress> {
  VideoPlayerController? controller;
  Future<void>? _initializeFuture;
  bool _hasStarted =
      false; // Flag para garantizar que se llame a play() solo una vez
  
  @override
  void initState() {
    super.initState();
    // Asigna el controlador global sin llamar a play() aquí.
    controller = VideoPlayerController.file(File(widget.videoPath))
      ..setLooping(true)
      ..setVolume(0);

    // Almacena el Future de inicialización para que FutureBuilder lo gestione.
    _initializeFuture = controller!.initialize();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFuture,
      builder: (context, snapshot) {
        // Mientras no se complete la inicialización, no se muestra nada.
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        // Una vez inicializado, se llama a play() una sola vez.
        if (!_hasStarted) {
          controller!.play();
          _hasStarted = true;
        }

        return Center(
          child: AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderVideo),
              child: GestureDetector(
                // Alterna reproducción al tocar - ahora cubre toda el área
                onTap: () {
                  if (controller!.value.isPlaying) {
                    controller!.pause();
                  } else {
                    controller!.play();
                  }
                },
                // Scrubbing: desplaza el timestamp del video al arrastrar horizontalmente
                onHorizontalDragUpdate: (details) {
                  // Obtiene la posición actual del video.
                  final currentPosition = controller!.value.position;

                  // Factor de sensibilidad (segundos por píxel).
                  const double sensitivity = 0.1;
                  // Calcula el cambio en milisegundos.
                  int deltaMs = (sensitivity * details.delta.dx * 1000).round();
                  final deltaDuration = Duration(milliseconds: deltaMs);

                  // Calcula la nueva posición sumando/restando el delta.
                  Duration newPosition = currentPosition + deltaDuration;

                  // Limita la nueva posición a los límites válidos.
                  if (newPosition < Duration.zero) {
                    newPosition = Duration.zero;
                  } else if (newPosition > controller!.value.duration) {
                    newPosition = controller!.value.duration;
                  }

                  // Actualiza la posición del video.
                  controller!.seekTo(newPosition);
                },
                child: Stack(
                  children: [
                    // Video
                    VideoPlayer(controller!),

                    // Visualización del timestamp en la esquina inferior izquierda.
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: controller!,
                          builder: (context, value, child) {
                            final currentPos = value.position;
                            return Text(
                              _formatDuration(currentPos),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),

                    // Overlay para mostrar el ícono "play" cuando el video está pausado.
                    Positioned.fill(
                      child: ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: controller!,
                        builder: (context, value, child) {
                          return AnimatedOpacity(
                            opacity: !value.isPlaying ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 150),
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
          ),
        );
      },
    );
  }
}