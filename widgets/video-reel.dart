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
    _initializeController();
  }

  void _initializeController() {
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true);
    _initializeFuture = controller!.initialize();
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
    controller?.dispose();
    super.dispose();
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