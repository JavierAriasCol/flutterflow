// Automatic FlutterFlow imports
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!
import 'dart:async';

class CustomAnimatedText extends StatefulWidget {
  const CustomAnimatedText({
    super.key,
    this.width,
    this.height,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.fontFamily,
    required this.animationDuration,
    required this.letterSpacing,
    this.animationDelay,
    this.onFinished,
    this.onProgressUpdate,
  });

  final double? width;
  final double? height;
  final String text;
  final double fontSize;
  final Color color;
  final String fontFamily;
  final int animationDuration;
  final double letterSpacing;
  final int? animationDelay;
  final Future Function()? onFinished;
  final Future Function(double progress)? onProgressUpdate;

  @override
  State<CustomAnimatedText> createState() => _CustomAnimatedTextState();
}

class _CustomAnimatedTextState extends State<CustomAnimatedText>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  List<Animation<double>> _letterAnimations = [];
  late List<String> _words;
  late List<int> _wordStartIndices;

  // 1. ESTADO para saber si la animación ha finalizado.
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

    // 2. LISTENER PARA EL PROGRESO DE LA ANIMACIÓN
    // Se ejecuta en cada fotograma ("tick") de la animación.
    _mainController.addListener(() {
      widget.onProgressUpdate?.call(_mainController.value);
    });

    // 3. LISTENER PARA EL ESTADO DE LA ANIMACIÓN
    // Se ejecuta cuando la animación empieza, se detiene o se completa.
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

    // ---------------------------------------------------------------------------
    // NUEVA LÓGICA DE INICIO CON RETRASO
    //
    // Propósito:
    // Retrasar el inicio de la animación según el parámetro 'animationDelay'.
    //
    // Funcionamiento:
    // Se usa un Future.delayed para esperar la cantidad de milisegundos
    // especificada antes de llamar a _mainController.forward(). Se comprueba
    // si el widget sigue "montado" (visible) para evitar errores si el
    // usuario navega a otra pantalla antes de que el retraso termine.
    // ---------------------------------------------------------------------------
    final delay = widget.animationDelay ?? 0;
    if (delay > 0) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          _mainController.forward();
        }
      });
    } else {
      _mainController.forward();
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
    // Si el texto o la duración cambian, se reinicia la animación.
    if (oldWidget.text != widget.text ||
        oldWidget.animationDuration != widget.animationDuration) {
      _words = widget.text.split(' ');
      _mainController.dispose();
      _setupAnimations();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        // La opacidad de cada letra está directamente ligada
                        // al valor de su animación correspondiente.
                        opacity:
                            _letterAnimations[startIndex + letterIndex].value,
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
