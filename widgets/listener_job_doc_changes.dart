// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ListenerJobDocChanges extends StatefulWidget {
  const ListenerJobDocChanges({
    super.key,
    this.width,
    this.height,
    required this.cJobPreviewFn,
    required this.jobDocReference,
    required this.preloaderState,
  });

  final double? width;
  final double? height;
  final Widget Function(JobsRecord jobDoc) cJobPreviewFn;
  final DocumentReference jobDocReference;
  final Widget Function() preloaderState;

  @override
  State<ListenerJobDocChanges> createState() => _ListenerJobDocChangesState();
}

class _ListenerJobDocChangesState extends State<ListenerJobDocChanges> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<JobsRecord>(
      stream: JobsRecord.getDocument(widget.jobDocReference),
      builder: (context, snapshot) {
        // Mostrar loading mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.preloaderState();
        }

        // Si hay error, mostrar error state
        if (snapshot.hasError) {
          return widget.preloaderState();
        }

        // Si no hay datos, mostrar empty state
        if (!snapshot.hasData) {
          return widget.preloaderState();
        }

        // Datos cargados exitosamente - construir el widget hijo
        final JobsRecord jobDoc = snapshot.data!;
        return widget.cJobPreviewFn(jobDoc);
      },
    );
  }
}
