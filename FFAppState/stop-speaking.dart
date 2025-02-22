
// Function to stop speaking
Future<void> stopSpeaking() async {
  try {
    await FFAppState().flutterTTS!.stop();
    FFAppState().update(() {
      FFAppState().audioPlaying = false;
    });
  } catch (e) {
    print('Error stopping speech: $e');
  }
}