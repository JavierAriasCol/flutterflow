// Media Kit and Video Player imports
import 'package:media_kit/media_kit.dart'; // Provides Player and Media
import 'package:media_kit_video/media_kit_video.dart'; // Provides VideoController

class SimpleMediaKit extends StatefulWidget {
  const SimpleMediaKit({super.key, this.width, this.height, required this.videoUrl});

  final double? width;
  final double? height;
  final String videoUrl;

  @override
  State<SimpleMediaKit> createState() => _SimpleMediaKitState();
}

class _SimpleMediaKitState extends State<SimpleMediaKit> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    // Ensure MediaKit is initialized
    MediaKit.ensureInitialized();
    // Initialize Player and Controller
    player = Player();
    controller = VideoController(player);

    player.open(Media(widget.videoUrl));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 9.0 / 16.0,
        // Use [Video] widget to display video output.
        child: Video(controller: controller),        
      ),
    );
  }
}