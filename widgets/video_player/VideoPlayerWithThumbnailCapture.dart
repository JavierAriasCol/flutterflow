import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPlayerWithThumbnailCapture extends StatefulWidget {
  const VideoPlayerWithThumbnailCapture({
    super.key,
    this.width,
    this.height,
    required this.videoPath,
    required this.indexState,
  });

  final double? width;
  final double? height;
  final String videoPath;
  final int indexState;

  @override
  _VideoPlayerWithThumbnailCaptureState createState() =>
      _VideoPlayerWithThumbnailCaptureState();
}

class _VideoPlayerWithThumbnailCaptureState
    extends State<VideoPlayerWithThumbnailCapture> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador con el archivo de video proporcionado.
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        // Opcional: iniciar reproducción automática o configurar controles
      });
  }

  Future<void> _captureThumbnail() async {
    // Verificamos que el video esté inicializado.
    if (!_controller.value.isInitialized) return;

    // Obtenemos la posición actual (timestamp) del video.
    final currentPosition = _controller.value.position;

    // Generamos la miniatura usando el timestamp actual.
    Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
      video: widget.videoPath,
      imageFormat: ImageFormat.PNG,
      timeMs: currentPosition.inMilliseconds,
      quality: 75,
    );

    if (thumbnailData != null) {
      // Convertimos la imagen a base64.
      String base64Thumbnail = base64Encode(thumbnailData);

      // Guardamos el thumbnail en la lista correspondiente del estado global.
      FFAppState()
          .uNewTread[widget.indexState]
          .videoUploaded
          .thumbList
          .add(base64Thumbnail);

      // Actualizamos el UI si es necesario.
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video player
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(
                height: 200,
                child: const Center(child: CircularProgressIndicator()),
              ),
        const SizedBox(height: 16),
        // Botón para capturar la miniatura en el timestamp actual.
        ElevatedButton(
          onPressed: _captureThumbnail,
          child: const Text('Capturar miniatura'),
        ),
        const SizedBox(height: 16),
        // Opcional: Mostrar la lista de miniaturas capturadas.
        Expanded(
          child: ListView.builder(
            itemCount: FFAppState()
                .uNewTread[widget.indexState]
                .videoUploaded
                .thumbList
                .length,
            itemBuilder: (context, index) {
              String base64Image = FFAppState()
                  .uNewTread[widget.indexState]
                  .videoUploaded
                  .thumbList[index];
              // Decodificamos el base64 para mostrar la imagen.
              Uint8List imageBytes = base64Decode(base64Image);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(imageBytes),
              );
            },
          ),
        ),
      ],
    );
  }
}