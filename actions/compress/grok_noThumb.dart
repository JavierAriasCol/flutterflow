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
import 'dart:async';
import 'package:v_video_compressor/v_video_compressor.dart';

// Variables globales para manejar la suscripción y el timer
StreamSubscription<VVideoProgressEvent>? _progressSubscription;
Timer? _videoProgressTimer;
final VVideoCompressor _compressor = VVideoCompressor();
Future<void> vVideoCompressor(String videoPath) async {
  // Limpiar y cancelar cualquier compresión anterior
  await cleanupCompression();
  // Cancelar cualquier compresión que pueda estar en curso
  try {
    await _compressor.cancelCompression();
    // Pequeña espera para asegurar que la cancelación se complete
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    // Ignorar errores si no hay compresión activa
  }
  // Actualizar el estado a "Cargando Video"
  FFAppState().update(() {
    FFAppState().uNewPost.videoLocal.status = "Subiendo video...";
    FFAppState().uNewPost.videoLocal.uploadProgress = 0.0;
    FFAppState().uNewPost.videoLocal.isCompressed = false;
    FFAppState().uNewPost.videoLocal.isCompressing = true;
    FFAppState().isCompressingVideo = true;
  });
  double currentProgress = 0.0;
  // Guardar la suscripción en la variable global
  _progressSubscription = VVideoCompressor.progressStream.listen((event) {
    currentProgress = event.progress;
  });
  // Guardar el timer en la variable global
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
    if (videoFile.existsSync()) {
      final compressionResult = await _compressor.compressVideo(
        videoPath,
        const VVideoCompressionConfig.medium(),
      );
      final compressedVideoPath = compressionResult?.compressedFilePath;
      if (compressedVideoPath == null) {
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
      // Eliminar el video original
      await videoFile.delete();
      FFAppState().update(() {
        FFAppState().uNewPost.videoLocal.status = "Carga completada";
        FFAppState().uNewPost.videoLocal.uploadProgress = 1.0;
        FFAppState().uNewPost.videoLocal.videoPath = compressedVideoPath;
        FFAppState().uNewPost.videoLocal.isCompressed = true;
        FFAppState().uNewPost.videoLocal.isCompressing = false;
        FFAppState().isCompressingVideo = false;
      });
    }
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
    await cleanupCompression();
  }
}

// Función para limpiar recursos
Future<void> cleanupCompression() async {
  _progressSubscription?.cancel();
  _progressSubscription = null;
  _videoProgressTimer?.cancel();
  _videoProgressTimer = null;
  await _compressor.cleanupFiles(
    deleteThumbnails: true,
    deleteCompressedVideos: false,
    clearCache: true,
  );
}
