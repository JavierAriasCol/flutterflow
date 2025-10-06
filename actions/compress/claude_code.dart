// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:v_video_compressor/v_video_compressor.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash_dart/blurhash_dart.dart';

// Variables globales para manejar la compresión y el timer
final VVideoCompressor _compressor = VVideoCompressor();
Timer? _videoProgressTimer;
bool _isCompressing = false;

Future<void> vVideoCompressor(String videoPath) async {
  // Limpiar y cancelar cualquier compresión anterior
  await cleanupCompression();

  // Cancelar cualquier compresión que pueda estar en curso
  try {
    if (_isCompressing) {
      await _compressor.cancelCompression();
      // Pequeña espera para asegurar que la cancelación se complete
      await Future.delayed(const Duration(milliseconds: 500));
    }
  } catch (e) {
    // Ignorar errores si no hay compresión activa
  }

  // Actualizar el estado a "Subiendo video..."
  FFAppState().update(() {
    FFAppState().uNewPost.videoLocal.status = "Subiendo video...";
    FFAppState().uNewPost.videoLocal.uploadProgress = 0.0;
    FFAppState().uNewPost.videoLocal.isCompressed = false;
    FFAppState().uNewPost.videoLocal.isCompressing = true;
    FFAppState().isCompressingVideo = true;
  });

  _isCompressing = true;
  double currentProgress = 0.0;

  // Configurar timer para actualizar el progreso periódicamente
  _videoProgressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    FFAppState().update(() {
      FFAppState().uNewPost.videoLocal.uploadProgress = currentProgress;
    });

    if (currentProgress >= 1.0) {
      timer.cancel();
    }
  });

  try {
    final videoFile = File(videoPath);

    if (!videoFile.existsSync()) {
      throw Exception("El archivo de video no existe");
    }

    // Configuración de compresión equivalente a Res960x540Quality
    const config = VVideoCompressionConfig(
      quality: VVideoCompressQuality.medium,
      advanced: VVideoAdvancedConfig(
        customWidth: 960,
        customHeight: 540,
        videoBitrate: 1800000,
        audioBitrate: 128000,
        videoCodec: VVideoCodec.h265,
        encodingSpeed: VEncodingSpeed.medium,
        frameRate: 30.0,
        autoCorrectOrientation: true,
        hardwareAcceleration: true,
      ),
    );

    // Comprimir video con seguimiento de progreso
    final compressionResult = await _compressor.compressVideo(
      videoPath,
      config,
      onProgress: (progress) {
        currentProgress = progress;
      },
      id: 'compress-${DateTime.now().millisecondsSinceEpoch}',
    );

    if (compressionResult == null) {
      FFAppState().update(() {
        FFAppState().uNewPost.videoLocal.status =
            "Falló la compresión del video";
        FFAppState().uNewPost.videoLocal.uploadProgress = 0.0;
        FFAppState().uNewPost.videoLocal.videoPath = null;
        FFAppState().uNewPost.videoLocal.isCompressed = false;
        FFAppState().uNewPost.videoLocal.isCompressing = false;
        FFAppState().isCompressingVideo = false;
      });
      return;
    }

    final compressedVideoPath = compressionResult.compressedFilePath;

    // Generar thumbnail usando el paquete v_video_compressor
    final thumbnailResult = await _compressor.getVideoThumbnail(
      compressedVideoPath,
      const VVideoThumbnailConfig(
        timeMs: 1000,
        maxWidth: 400,
        maxHeight: 400,
        format: VThumbnailFormat.jpeg,
        quality: 75,
      ),
    );

    String? iniThumbnail;
    String? iniBlur;

    if (thumbnailResult != null) {
      // Leer el archivo de thumbnail
      final thumbnailFile = File(thumbnailResult.thumbnailPath);
      final thumbnailData = await thumbnailFile.readAsBytes();

      iniThumbnail = base64Encode(thumbnailData);

      // Generar blurhash
      final decodedImage = img.decodeImage(thumbnailData);
      if (decodedImage != null) {
        final blurHash = BlurHash.encode(
          decodedImage,
          numCompX: 4,
          numCompY: 3,
        );
        iniBlur = blurHash.hash;
      }
    }

    // Eliminar el video original si la compresión fue exitosa
    try {
      if (videoFile.existsSync() && compressedVideoPath != videoPath) {
        await videoFile.delete();
      }
    } catch (e) {
      // Ignorar error si no se puede eliminar el original
    }

    // Actualizar estado final
    FFAppState().update(() {
      FFAppState().uNewPost.videoLocal.status = "Carga completada";
      FFAppState().uNewPost.videoLocal.uploadProgress = 1.0;
      FFAppState().uNewPost.videoLocal.videoPath = compressedVideoPath;
      FFAppState().uNewPost.videoLocal.isCompressed = true;
      FFAppState().uNewPost.videoLocal.isCompressing = false;
      FFAppState().uNewPost.video.iniThumbnail = iniThumbnail;
      FFAppState().uNewPost.video.iniBlur = iniBlur;
      FFAppState().isCompressingVideo = false;
    });
  } on Exception catch (e) {
    FFAppState().update(() {
      FFAppState().uNewPost.videoLocal.status =
          "Error en la compresión: ${e.toString()}";
      FFAppState().uNewPost.videoLocal.uploadProgress = 0.0;
      FFAppState().uNewPost.videoLocal.videoPath = null;
      FFAppState().uNewPost.videoLocal.isCompressed = false;
      FFAppState().uNewPost.videoLocal.isCompressing = false;
      FFAppState().isCompressingVideo = false;
    });
    return;
  } finally {
    _isCompressing = false;
    await cleanupCompression();
  }
}

// Función para limpiar recursos
Future<void> cleanupCompression() async {
  _videoProgressTimer?.cancel();
  _videoProgressTimer = null;

  // Limpiar thumbnails generados pero mantener videos comprimidos
  try {
    await _compressor.cleanupFiles(
      deleteThumbnails: true,
      deleteCompressedVideos: false, // Mantener videos comprimidos
      clearCache: true,
    );
  } catch (e) {
    // Ignorar errores de limpieza
  }
}
