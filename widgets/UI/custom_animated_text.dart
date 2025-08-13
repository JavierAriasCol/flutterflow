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
    this.completeAnimation = false,
    this.percentageTrigger = 0.2,
    this.actionTriggered,
    this.onFinished,
  });

  final double? width;
  final double height;
  final String text;
  final double fontSize;
  final Color color;
  final String fontFamily;
  final int animationDuration;
  final double? letterSpacing;
  final bool? completeAnimation;
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

    _mainController.forward();
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
