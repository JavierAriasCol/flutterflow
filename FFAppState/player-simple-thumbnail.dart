// En Dart, debido a la seguridad de nulos, se usan operadores especiales para trabajar con variables que pueden o no contener un valor (ser nulas). Aquí se explican los operadores en los ejemplos que diste:

// - **`FFAppState().flutterTTS!`**  
//   El signo de exclamación `!` se conoce como **operador de aserción de no nulidad**. Se usa para indicarle al compilador que, aunque `flutterTTS` esté declarado como nullable (es decir, puede ser nulo), en este momento estás seguro de que tiene un valor. Si por error fuese nulo, se lanzaría una excepción en tiempo de ejecución.

// - **`FFAppState().videoController?`**  
//   El signo de interrogación `?` en este contexto forma parte de un **operador de acceso seguro** (null-aware operator). Por ejemplo, cuando escribes algo como `FFAppState().videoController?.dispose()`, le estás diciendo al compilador: "Si `videoController` no es nulo, ejecuta `dispose()`, de lo contrario, no hagas nada." Es una manera segura de llamar a métodos o acceder a propiedades sin causar un error si la variable es nula.

// - **`FFAppState().videoController!`**  
//   Similar al primer caso, aquí el `!` se usa para afirmar que `videoController` no es nulo en ese punto del código. Esto permite acceder a sus métodos o propiedades sin que el compilador se queje, asumiendo que efectivamente se ha inicializado.

// En resumen:

// - El **`!`** se utiliza para **afirmar** que una variable nullable **no es nula** en ese momento.
// - El **`?`** se utiliza para **realizar operaciones de forma segura** sobre una variable que puede ser nula, evitando errores si efectivamente lo es.

import 'dart:io';
import 'package:video_player/video_player.dart';

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
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    // Asigna el controlador global sin reproducir el video.
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

  // Función auxiliar para formatear la duración (min:seg).
  String _formatDuration(Duration position) {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

        // Construye el reproductor en un Stack para superponer el timestamp.
        return Center(
          child: AspectRatio(
            aspectRatio: FFAppState().videoController!.value.aspectRatio,
            child: Stack(
              children: [
                // Gesto para scrubbing (avanzar/retroceder arrastrando horizontalmente).
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // Posición actual del video.
                    final currentPosition =
                        FFAppState().videoController!.value.position;

                    // Factor de sensibilidad (segundos por píxel).
                    const double sensitivity = 0.1;
                    // Delta en milisegundos.
                    int deltaMs =
                        (sensitivity * details.delta.dx * 1000).round();
                    final deltaDuration = Duration(milliseconds: deltaMs);

                    // Calcula la nueva posición sumando/restando el delta.
                    Duration newPosition = currentPosition + deltaDuration;

                    // Asegura que no salga de los límites (0 <-> duración total).
                    if (newPosition < Duration.zero) {
                      newPosition = Duration.zero;
                    } else if (newPosition >
                        FFAppState().videoController!.value.duration) {
                      newPosition =
                          FFAppState().videoController!.value.duration;
                    }

                    // Actualiza la posición del video.
                    FFAppState().videoController!.seekTo(newPosition);
                  },
                  child: VideoPlayer(FFAppState().videoController!),
                ),

                // Timestamp en la esquina inferior izquierda.
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    color: Colors.black54,
                    child: ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: FFAppState().videoController!,
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
              ],
            ),
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

