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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderVideo),
                  child: VideoPlayer(controller!),
                ),
              ],
            ),
          )
        );
      },
    );
  }
}