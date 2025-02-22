import 'dart:io';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPlayerWithThumbnails extends StatefulWidget {
  const VideoPlayerWithThumbnails({
    super.key,
    this.width,
    this.height,
    required this.videoPath,
  });

  final double? width;
  final double? height;
  final String videoPath;

  @override
  _VideoPlayerWithThumbnailsState createState() =>
      _VideoPlayerWithThumbnailsState();
}

class _VideoPlayerWithThumbnailsState extends State<VideoPlayerWithThumbnails> {
  late VideoPlayerController _controller;
  List<Uint8List>? _thumbnails;
  int _currentThumbnailIndex = 0;
  final int _thumbCount = 10; // número de miniaturas a generar

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _generateThumbnails();
      });
    _controller.addListener(_updateSliderPosition);
  }

  Future<void> _generateThumbnails() async {
    final duration = _controller.value.duration;
    final int interval = duration.inSeconds ~/ _thumbCount;
    List<Uint8List> thumbs = [];
    for (int i = 0; i < _thumbCount; i++) {
      final time = Duration(seconds: i * interval);
      final thumb = await VideoThumbnail.thumbnailData(
        video: widget.videoPath, // Ruta del video seleccionado
        imageFormat: ImageFormat.PNG,
        timeMs: time.inMilliseconds,
        quality: 75,
      );
      if (thumb != null) {
        thumbs.add(thumb);
      }
    }
    setState(() {
      _thumbnails = thumbs;
    });
  }

  void _updateSliderPosition() {
    if (_controller.value.isInitialized) {
      final currentPosition = _controller.value.position;
      final duration = _controller.value.duration;
      final newIndex =
          (currentPosition.inSeconds / duration.inSeconds * _thumbCount)
              .floor();
      if (newIndex != _currentThumbnailIndex) {
        setState(() {
          _currentThumbnailIndex = newIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reproductor de video
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(
                height: 200,
                child: const Center(child: CircularProgressIndicator()),
              ),
        const SizedBox(height: 16),
        // Slider de miniaturas
        _thumbnails != null
            ? SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _thumbnails!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        final duration = _controller.value.duration;
                        final position = Duration(
                          seconds: ((duration.inSeconds / _thumbnails!.length) *
                                  index)
                              .round(),
                        );
                        _controller.seekTo(position);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: _currentThumbnailIndex == index
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                          ),
                          child: Image.memory(
                            _thumbnails![index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const CircularProgressIndicator(),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateSliderPosition);
    _controller.dispose();
    super.dispose();
  }
}