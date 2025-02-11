import 'dart:io';
import 'package:video_compress/video_compress.dart';
import 'dart:async';

Future<bool> compressVideo(String videoPath, int indexState) async {
  // Actualizar el estado a "Cargando Video" para el elemento en la posición indexState
  FFAppState().update(() {
    FFAppState().uNewTread[indexState].videoUploaded.statusText =
        "Subiendo video...";
    FFAppState().uNewTread[indexState].videoUploaded.uploadProgress = 0.0;
    FFAppState().uNewTread[indexState].videoUploaded.isCompressed = false;
    FFAppState().uNewTread[indexState].videoUploaded.isCompressing = true;
  });

  // Configurar un listener para el progreso de la compresión
  final subscription = VideoCompress.compressProgress$.subscribe((progress) {
    // Actualizar el estado de la aplicación con el progreso de compresión
    FFAppState().update(() {
      FFAppState().uNewTread[indexState].videoUploaded.uploadProgress =
          progress / 100.0;
    });
  });

  try {
    // Comprimir el video
    final info = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.Res960x540Quality,
      deleteOrigin: false,
    );

    // Verificar si la compresión fue exitosa
    final compressedVideoPath = info?.file?.path;
    if (compressedVideoPath == null) {
      print('Falló la carga del video');
      FFAppState().update(() {
        FFAppState().uNewTread[indexState].videoUploaded.statusText =
            "Falló la carga del video";
        FFAppState().uNewTread[indexState].videoUploaded.uploadProgress = 0.0;
      });
      return false;
    }

    // Actualizar el estado para indicar que la compresión se completó
    FFAppState().update(() {
      FFAppState().uNewTread[indexState].videoUploaded.statusText =
          "Carga completada";
      FFAppState().uNewTread[indexState].videoUploaded.uploadProgress = 1.0;
      FFAppState().uNewTread[indexState].videoUploaded.videoPath =
          compressedVideoPath;
      FFAppState().uNewTread[indexState].videoUploaded.isCompressed = true;
      FFAppState().uNewTread[indexState].videoUploaded.isCompressing = false;
    });

    return true;
  } finally {
    // Asegurarse de desuscribirse, sin importar el resultado o si ocurrió alguna excepción.
    subscription.unsubscribe();
  }
}