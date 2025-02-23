import 'package:video_player/video_player.dart';
import 'dart:io';

class LocalVideoCompress extends StatefulWidget {
  const LocalVideoCompress({
    super.key,
    this.width,
    this.height,
    required this.videoPath,
  });

  final double? width;
  final double? height;
  final String videoPath;

  @override
  State<LocalVideoCompress> createState() => _LocalVideoCompressState();
}

class _LocalVideoCompressState extends State<LocalVideoCompress> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = VideoPlayerController.file(File(widget.videoPath))
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          controller?.play();
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
      return const SizedBox.shrink();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: VideoPlayer(controller!),
      ),
    );
  }
}