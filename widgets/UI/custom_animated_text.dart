// Automatic FlutterFlow imports
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class CustomAnimatedText extends StatefulWidget {
  const CustomAnimatedText({
    super.key,
    this.width,
    this.height = 60.0,
    required this.text,
    this.fontSize = 16.0,
    this.color = Colors.white,
    this.fontFamily = 'Merriweather',
    this.animationDuration = 200,
    this.letterSpacing = 0,
    this.completedAnimation = false, // <-- Usaremos este parámetro
    this.percentageTrigger = 0.2,
    this.actionTriggered,
    this.onFinished, // <-- Y esta acción
  });

  final double? width;
  final double height;
  final String text;
  final double fontSize;
  final Color color;
  final String fontFamily;
  final int animationDuration;
  final double? letterSpacing;
  final bool? completedAnimation;
  final double? percentageTrigger;
  final Future Function()? actionTriggered;
  final Future Function()? onFinished;

  @override
  State<CustomAnimatedText> createState() => _CustomAnimatedTextState();
}

class _CustomAnimatedTextState extends State<CustomAnimatedText>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  List<Animation<double>> _letterAnimations = [];
  late List<String> _words;
  late List<int> _wordStartIndices;

  // 1. NUEVO ESTADO para saber si la animación ha finalizado.
  bool _isAnimationCompleted = false;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    _setupAnimations();
  }

  void _setupAnimations() {
    final totalCharacters = widget.text.length;
    _mainController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: totalCharacters * widget.animationDuration,
      ),
    );

    // 2. AÑADIMOS UN LISTENER al controlador.
    // Se ejecutará cada vez que el estado de la animación cambie (ej: en curso, completada).
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Si la animación se completa de forma natural...
        if (!_isAnimationCompleted) {
          // Prevenimos múltiples llamadas
          setState(() {
            _isAnimationCompleted = true; // Actualizamos nuestro estado
          });
          widget.onFinished?.call(); // Disparamos la acción onFinished
        }
      }
    });

    int currentChar = 0;
    _letterAnimations = [];
    _wordStartIndices = [];

    for (String word in _words) {
      _wordStartIndices.add(_letterAnimations.length);
      for (int i = 0; i < word.length; i++) {
        final begin = currentChar * (1.0 / totalCharacters);
        final end = (currentChar + 1) * (1.0 / totalCharacters);

        _letterAnimations.add(
          Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _mainController,
              curve: Interval(begin, end, curve: Curves.easeInOut),
            ),
          ),
        );
        currentChar++;
      }
      // Account for space between words
      currentChar++;
    }

    // 3. LÓGICA DE INICIO
    // Si completedAnimation es true desde el principio, la completamos inmediatamente.
    if (widget.completedAnimation == true) {
      _mainController.value = 1.0; // Saltamos al final de la animación
      _isAnimationCompleted = true; // Marcamos el estado como completado
      // La acción onFinished se llama en el build para este caso.
    } else {
      _mainController.forward(); // Si no, iniciamos la animación normalmente.
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomAnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.animationDuration != widget.animationDuration) {
      _words = widget.text.split(' ');
      _mainController.dispose();
      _setupAnimations();
    }

    // 4. MANEJO DE ACTUALIZACIÓN
    // Si el parámetro completedAnimation cambia a 'true' mientras el widget ya existe.
    if (widget.completedAnimation == true &&
        oldWidget.completedAnimation == false) {
      if (!_isAnimationCompleted) {
        // Solo si no estaba ya completada
        _mainController.value = 1.0; // Saltamos la animación al final
        setState(() {
          _isAnimationCompleted = true; // Actualizamos el estado
        });
        widget.onFinished?.call(); // Disparamos la acción
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. MANEJO ESPECIAL DE onFinished CUANDO SE COMPLETA EN EL INICIO
    // Usamos addPostFrameCallback para asegurar que la acción se ejecute de forma segura
    // después de que el frame inicial se haya construido.
    if (widget.completedAnimation == true && !_isAnimationCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onFinished?.call();
        }
      });
    }

    // Si la animación debe mostrarse completa (ya sea por el parámetro o por estado),
    // la opacidad es 1.0. Si no, usamos el valor de la animación.
    final bool isCompleted =
        widget.completedAnimation == true || _isAnimationCompleted;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: SingleChildScrollView(
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: widget.fontSize * 0.25, // Space between words
            runSpacing: widget.fontSize * 0.5, // Space between lines
            children: List.generate(_words.length, (wordIndex) {
              String word = _words[wordIndex];
              int startIndex = _wordStartIndices[wordIndex];

              return AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      word.length,
                      (letterIndex) => Opacity(
                        // 6. LÓGICA DE OPACIDAD ACTUALIZADA
                        opacity: isCompleted
                            ? 1.0
                            : _letterAnimations[startIndex + letterIndex].value,
                        child: Text(
                          word[letterIndex],
                          style: TextStyle(
                            fontSize: widget.fontSize,
                            fontFamily: widget.fontFamily,
                            color: widget.color,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                            letterSpacing: widget.letterSpacing,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
