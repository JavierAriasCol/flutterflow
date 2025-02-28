import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash_dart/blurhash_dart.dart';

Future<bool> compressVideo(String videoPath, int indexState) async {
  // Actualizar el estado a "Cargando Video" para el elemento en la posición indexState
  FFAppState().update(() {
    FFAppState().uNewTread[indexState].videoUploaded.statusText =
        "Subiendo video...";
    FFAppState().uNewTread[indexState].videoUploaded.uploadProgress = 0.0;
    FFAppState().uNewTread[indexState].videoUploaded.isCompressed = false;
    FFAppState().uNewTread[indexState].videoUploaded.isCompressing = true;
    
    /* El usuario no puede subir otro video */
    FFAppState().isCompressingVideo = true;
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
      deleteOrigin: true,
    );

    // Verificar si la compresión fue exitosa
    final compressedVideoPath = info?.file?.path;
    if (compressedVideoPath == null) {
      print('Falló la carga del video');
      FFAppState().update(() {
        FFAppState().uNewTread[indexState].videoUploaded.statusText =
            "Falló la carga del video";
        FFAppState().uNewTread[indexState].videoUploaded.uploadProgress = 0.0;
        // Se podría asignar null a videoPath si es necesario
        FFAppState().uNewTread[indexState].videoUploaded.videoPath = null;
        FFAppState().uNewTread[indexState].videoUploaded.isCompressed = false;
        FFAppState().uNewTread[indexState].videoUploaded.isCompressing = false;
        
        /* El usuario puede subir otro video */
        FFAppState().isCompressingVideo = false;
      });
      return false;
    }
    
    // Capturar el thumbnail usando el videoPath comprimido
    final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
      video: compressedVideoPath,
      imageFormat: ImageFormat.WEBP,
      timeMs: 1000, // captura en el segundo 1
      quality: 75,
    );
    
    String? iniThumbnail;
    String? iniBlur;
    if (thumbnailData != null) {
      // Convertir la miniatura a Base64.
      iniThumbnail = base64Encode(thumbnailData);
      
      // Decodificar la imagen para generar el Blur Hash.
      final decodedImage = img.decodeImage(thumbnailData);
      if (decodedImage != null) {
        final blurHash = BlurHash.encode(decodedImage, numCompX: 4, numCompY: 3);
        iniBlur = blurHash.hash;
      }
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
      // Actualizamos el thumbnail y el Blur Hash usando los valores obtenidos
      FFAppState().uNewTread[indexState].videoUploaded.iniThumbnail = iniThumbnail;
      FFAppState().uNewTread[indexState].videoUploaded.iniBlur = iniBlur;
      
      /* El usuario puede subir otro video */
      FFAppState().isCompressingVideo = false;
    });
    
    return true;
  } on Exception catch (e) {
    // Manejo de excepción: registrar error y actualizar estado
    print("Error al comprimir video: $e");
    FFAppState().update(() {
      FFAppState().uNewTread[indexState].videoUploaded.statusText =
          "Error en la compresión";
      FFAppState().uNewTread[indexState].videoUploaded.uploadProgress = 0.0;
      // Se podría asignar null a videoPath si es necesario
      FFAppState().uNewTread[indexState].videoUploaded.videoPath = null;
      FFAppState().uNewTread[indexState].videoUploaded.isCompressed = false;
      FFAppState().uNewTread[indexState].videoUploaded.isCompressing = false;
      
      /* El usuario puede subir otro video */
      FFAppState().isCompressingVideo = false;
    });
    return false;
  } finally {
    // Asegurarse de desuscribirse sin sobrescribir información importante
    subscription.unsubscribe();
    // Se evita actualizar el estado en finally para no interferir con las actualizaciones previas.
  }
}