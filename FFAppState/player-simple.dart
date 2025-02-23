import 'package:video_player/video_player.dart';
import 'dart:io';

class LocalVideoThumbnail extends StatefulWidget {
  const LocalVideoThumbnail({
    super.key,
    this.width,
    this.height,
    required this.videoPath,
  });

  final double? width;
  final double? height;
  final String videoPath;

  @override
  State<LocalVideoThumbnail> createState() => _LocalVideoThumbnailState();
}

class _LocalVideoThumbnailState extends State<LocalVideoThumbnail> {
  Future<void>? _initializeFuture;
  bool _hasStarted =
      false; // Flag para garantizar que se llame a play() solo una vez

  @override
  void initState() {
    super.initState();
    // Asigna el controlador global sin llamar a play() aquí.
    FFAppState().videoController =
        VideoPlayerController.file(File(widget.videoPath))
          ..setLooping(true)
          ..setVolume(0);

    // Almacena el Future de inicialización para que FutureBuilder lo gestione.
    _initializeFuture = FFAppState().videoController!.initialize();
  }

  @override
  void dispose() {
    // Libera el controlador global y lo establece en null.
    FFAppState().videoController?.dispose();
    FFAppState().videoController = null;
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
          FFAppState().videoController!.play();
          _hasStarted = true;
        }

        return Center(
          child: AspectRatio(
            aspectRatio: FFAppState().videoController!.value.aspectRatio,
            child: VideoPlayer(FFAppState().videoController!),
          ),
        );
      },
    );
  }
}

// La implementación en este fragmento de código es correcta, siempre y cuando se cumplan algunos supuestos:

// 1. **Definición de FFAppState:**  
//    Se asume que `FFAppState` está definido en tu proyecto y tiene una propiedad mutable `videoController` (por ejemplo, de tipo `VideoPlayerController?`). Esto permite asignar, usar y disponer el controlador de video globalmente.

// 2. **Asignación y Uso del Controlador Global:**  
//    - En `_initializeController()`, se asigna a `FFAppState().videoController` el controlador creado con el video seleccionado.  
//    - Se configura correctamente el controlador (looping, volumen, inicialización) y se inicia la reproducción al finalizar la inicialización.
//    - En `build()`, se consulta el controlador global para construir la UI, verificando que no sea `null` y que esté inicializado.

// 3. **Liberación de Recursos:**  
//    En el método `dispose()`, se dispone del controlador global y se establece a `null`, lo que es adecuado para evitar fugas de memoria.

// En resumen, el uso de `FFAppState` como contenedor del controlador de video se implementa correctamente en este código, siempre y cuando la clase `FFAppState` esté definida y tenga la propiedad `videoController` de manera coherente en toda la aplicación.

