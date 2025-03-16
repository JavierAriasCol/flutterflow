// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

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
    // Limpiar controladores antiguos antes de inicializar uno nuevo
    _cleanupOldControllers();
    _initializeController();
  }

  void _initializeController() {
    // Buscar si ya existe un controlador para este video en el estado global
    final existingIndex = FFAppState()
        .videoReelController
        .indexWhere((item) => item is Map && item['id'] == widget.videoguid);

    if (existingIndex >= 0) {
      // Usar el controlador existente
      controller = FFAppState().videoReelController[existingIndex]['controller']
          as VideoPlayerController;

      // Verificar si el controlador ya está inicializado
      if (controller!.value.isInitialized) {
        _initializeFuture =
            Future.value(); // El controlador ya está inicializado
        print(
            'Reutilizando controlador inicializado para video: ${widget.videoguid}');
      } else {
        // Si no está inicializado, inicializarlo
        _initializeFuture = controller!.initialize();
        print(
            'Inicializando controlador reutilizado para video: ${widget.videoguid}');
      }

      // Actualizar el timestamp para mantener este controlador como reciente
      if (FFAppState().videoReelController[existingIndex] is Map) {
        (FFAppState().videoReelController[existingIndex] as Map)['timestamp'] =
            DateTime.now().millisecondsSinceEpoch;
      }
    } else {
      // Crear un nuevo controlador
      controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..setLooping(true);

      // Almacenar en el estado global
      FFAppState().addToVideoReelController({
        'id': widget.videoguid,
        'controller': controller,
        'url': widget.videoUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Inicializar el controlador con manejo de errores
      _initializeFuture = controller!.initialize().catchError((error) {
        print(
            'Error al inicializar controlador para video ${widget.videoguid}: $error');

        // Eliminar el controlador fallido del estado global
        final failedIndex = FFAppState().videoReelController.indexWhere(
            (item) => item is Map && item['id'] == widget.videoguid);

        if (failedIndex >= 0) {
          FFAppState().removeAtIndexFromVideoReelController(failedIndex);
        }

        // Propagar el error para que FutureBuilder pueda manejarlo
        return Future.error(error);
      });

      print('Nuevo controlador creado para video: ${widget.videoguid}');
    }
  }

  void _togglePlayPause() {
    controller!.value.isPlaying ? controller!.pause() : controller!.play();
  }

  Widget _buildProgressBar() {
    if (controller == null || !controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return VideoProgressIndicator(
      controller!,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: Colors.red.shade700,
        bufferedColor: Colors.white70,
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  void dispose() {
    // No disponer del controlador si está en el estado global
    // Solo verificamos si existe en el estado global
    final existingIndex = FFAppState()
        .videoReelController
        .indexWhere((item) => item is Map && item['id'] == widget.videoguid);

    // Si no está en el estado global, lo disponemos normalmente
    if (existingIndex < 0 && controller != null) {
      controller!.dispose();
      print('Controlador dispuesto para video: ${widget.videoguid}');
    } else {
      print('Controlador mantenido en estado global: ${widget.videoguid}');
    }

    super.dispose();
  }

  // Método para limpiar controladores antiguos (puede ser llamado periódicamente)
  void _cleanupOldControllers() {
    // Ejemplo: mantener solo los 5 controladores más recientes
    if (FFAppState().videoReelController.length > 5) {
      // Ordenar por timestamp (más reciente primero)
      FFAppState().videoReelController.sort((a, b) {
        if (a is Map && b is Map) {
          final timestampA = a['timestamp'] ?? 0;
          final timestampB = b['timestamp'] ?? 0;
          return timestampB.compareTo(timestampA);
        }
        return 0;
      });

      // Eliminar los más antiguos
      final controllersToRemove = FFAppState().videoReelController.sublist(5);
      for (final item in controllersToRemove) {
        if (item is Map && item['controller'] is VideoPlayerController) {
          (item['controller'] as VideoPlayerController).dispose();
          print('Controlador antiguo dispuesto: ${item['id']}');
        }
      }

      // Mantener solo los 5 más recientes
      FFAppState().videoReelController =
          FFAppState().videoReelController.sublist(0, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoguid),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction >= 0.5) {
          if (!_hasStarted || controller?.value.isPlaying == false) {
            controller?.play();
            _hasStarted = true;
          }
        } else {
          controller?.pause();
          controller?.seekTo(Duration.zero);
        }
      },
      child: FutureBuilder(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 1, color: Colors.white),
            );
          }

          // Mostrar mensaje de error si hay un problema
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Error al cargar el video',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () => widget.onDoubleTap(widget.postId),
                  onTap: _togglePlayPause,
                  child: Center(
                    // Añadido Center para mantener el aspect ratio
                    child: AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(controller!),
                          ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: controller!,
                            builder: (context, value, _) {
                              return Stack(
                                children: [
                                  if (value.isBuffering)
                                    const Positioned.fill(
                                      // Ocupa toda el área disponible
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  AnimatedOpacity(
                                    opacity: value.isPlaying ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 100),
                                    child: const _PlayIcon(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildProgressBar(),
            ],
          );
        },
      ),
    );
  }
}

class _PlayIcon extends StatelessWidget {
  const _PlayIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}