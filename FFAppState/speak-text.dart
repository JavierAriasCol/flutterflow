import 'package:flutter_tts/flutter_tts.dart';

bool _isInitialized = false;

// Initialize the TTS settings
Future<void> initializeTTS() async {
  if (!_isInitialized) {
    // Initialize the FlutterTTS instance if it doesn´t exist yet.
    FFAppState().flutterTTS ??= FlutterTts();

    await FFAppState().flutterTTS!.setLanguage("en-US");
    await FFAppState().flutterTTS!.setPitch(1.0);
    await FFAppState().flutterTTS!.setSpeechRate(0.5);

    await FFAppState().flutterTTS!.setStartHandler(() {
      FFAppState().update(() {
        FFAppState().audioPlaying = true;
      });
      print('Started Speaking');
      });

      FFAppState().flutterTTS!.setCompletionHandler(() {
        FFAppState().update(() {
          FFAppState().audioPlaying = false;
        });
        print('Completed Speaking');
      });

      FFAppState().flutterTTS!.setErrorHandler((error) {
        FFAppState().update(() {
          FFAppState().audioPlaying = false;
        });
        print('Error: $error');
      });
      
    _isInitialized = true;
  }
}

// Function to speak text
Future<void> speakText(String text) async {
  try {
    await initializeTTS();
    await FFAppState().flutterTTS!.stop();
    await FFAppState().flutterTTS!.speak(text);
  } catch (e) {
    print('Error speaking text: $e');
    FFAppState().update(() {
      FFAppState().audioPlaying = false;
    });
  }
}