import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

Future<MsgSelectVideoStruct> selectVideo() async {
  final ImagePicker _picker = ImagePicker();

  // Permite seleccionar un video desde la galería.
  final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

  // statusCode = 1, cuando no se selecciona ningún video.
  if (video == null) {
    return MsgSelectVideoStruct(
        videoPath: '', statusCode: 1, aspectRatio: 0.0, videoDuration: 0);
  }

  // Verificar que el video sea .mp4 (se compara en minúsculas para evitar problemas)
  final String extension = p.extension(video.path).toLowerCase();
  // statusCode = 2, cuando no cumple con el formato .mp4.
  if (extension != '.mp4') {
    return MsgSelectVideoStruct(
        videoPath: '', statusCode: 2, aspectRatio: 0.0, videoDuration: 0);
  }

  // Usamos VideoPlayerController para obtener la duración y el aspect ratio del video.
  final VideoPlayerController controller =
      VideoPlayerController.file(File(video.path));

  // Inicializamos el controlador para poder acceder a la duración y el aspect ratio.
  await controller.initialize();
  final int videoDuration = controller.value.duration.inMilliseconds;
  final double aspectRatio = controller.value.aspectRatio;
  await controller.dispose(); // Liberamos recursos

  // statusCode = 3, cuando el video excede los 5 minutos.
  if (videoDuration > 300000) {
    return MsgSelectVideoStruct(
        videoPath: '', statusCode: 3, aspectRatio: 0.0, videoDuration: 0);
  }

  // statusCode = 4, video inferior de 5 segundos.
  if (videoDuration < 5000) {
    return MsgSelectVideoStruct(
        videoPath: '', statusCode: 4, aspectRatio: 0.0, videoDuration: 0);
  }

  // statusCode = 0, se cumple con todas las condiciones.
  return MsgSelectVideoStruct(
      title:
          '${FFAppState().uProfile.username} ${DateTime.now().millisecondsSinceEpoch}',
      videoPath: video.path,
      statusCode: 0,
      aspectRatio: aspectRatio,
      videoDuration: videoDuration);
}