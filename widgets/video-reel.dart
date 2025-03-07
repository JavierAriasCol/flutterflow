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
  });

  final double? width;
  final double? height;
  final String videoUrl;
  final String postId;
  final Future Function(String postId) onDoubleTap;

  @override
  State<VideoReel> createState() => _VideoReelState();
}

class _VideoReelState extends State<VideoReel> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
          child:
              CircularProgressIndicator(strokeWidth: 1, color: Colors.white));
    }

    return VisibilityDetector(
      key: Key(widget.videoUrl), // Usar videoUrl como identificador único
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction >= 0.8) {
          controller?.play();
        } else {
          controller?.pause();
          controller?.seekTo(Duration.zero); // Regresamos a la posición inicial
        }
      },
      child: GestureDetector(
        // Añadimos solo el GestureDetector
        onDoubleTap: () => widget.onDoubleTap(widget.postId),
        child: ValueListenableBuilder(
          valueListenable: controller!,
          builder: (context, VideoPlayerValue value, child) {
            return Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(controller!),
                  ),
                ),
                if (value.isBuffering)
                  const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: Colors.white),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}