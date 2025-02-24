import 'package:video_player/video_player.dart';
import 'dart:io';

class LocalVideoPlayer extends StatefulWidget {
  const LocalVideoPlayer({
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
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderVideo),
                  child: GestureDetector(
                    onTap: () {
                      if (controller!.value.isPlaying) {
                        controller!.pause();
                      } else {
                        controller!.play();
                      }
                    },
                    child: VideoPlayer(controller!),
                  ),
                ),
                Positioned.fill(
                child: AnimatedOpacity(
                opacity: !_isPlaying ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 30,
                    color: Colors.white60,
                  ),
                ),
              ),
            ),
              ],
            ),
          )
        );
      },
    );
  }
}