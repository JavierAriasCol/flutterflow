import '/backend/schema/structs/index.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_maps_flutter/google_maps_flutter.dart'
    as google_maps_flutter;
import '/flutter_flow/lat_lng.dart' as latlng;
import 'dart:async';
export 'dart:async' show Completer;
export 'package:google_maps_flutter/google_maps_flutter.dart' hide LatLng;
export '/flutter_flow/lat_lng.dart' show LatLng;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'dart:ui';

class DataTypeMap extends StatefulWidget {
  const DataTypeMap({
    super.key,
    this.width,
    this.height,
    this.places,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.showLocation,
    required this.showCompass,
    required this.showMapToolbar,
    required this.showTraffic,
    required this.allowZoom,
    required this.showZoomControls,
    required this.defaultZoom,
    this.onClickMarker,
  });

  final double? width;
  final double? height;
  final List<PlaceStruct>? places;
  final double centerLatitude;
  final double centerLongitude;
  final bool showLocation;
  final bool showCompass;
  final bool showMapToolbar;
  final bool showTraffic;
  final bool allowZoom;
  final bool showZoomControls;
  final double defaultZoom;
  final Future Function(PlaceStruct? placeRow)? onClickMarker;

  @override
  State<DataTypeMap> createState() => _DataTypeMapState();
}

class _DataTypeMapState extends State<DataTypeMap> {
  Completer<google_maps_flutter.GoogleMapController>? _controller;
  final Map<String, google_maps_flutter.BitmapDescriptor> _customIcons = {};
  Set<google_maps_flutter.Marker> _markers = {};

  late google_maps_flutter.LatLng _center;

  @override
  void initState() {
    super.initState();
    _resetController();
    _center = google_maps_flutter.LatLng(
        widget.centerLatitude, widget.centerLongitude);
    _loadMarkerIcons();
  }

  void _resetController() {
    _controller = Completer<google_maps_flutter.GoogleMapController>();
  }

  @override
  void didUpdateWidget(DataTypeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Actualizar centro si cambian las coordenadas
    if (oldWidget.centerLatitude != widget.centerLatitude ||
        oldWidget.centerLongitude != widget.centerLongitude) {
      _center = google_maps_flutter.LatLng(
          widget.centerLatitude, widget.centerLongitude);
    }
    
    // Recargar marcadores si cambian los lugares
    if (oldWidget.places != widget.places) {
      _loadMarkerIcons();
    }
  }

  Future<void> _loadMarkerIcons() async {
    // Limpiar iconos anteriores si es necesario
    if (widget.places == null || widget.places!.isEmpty) {
      setState(() {
        _markers = {};
      });
      return;
    }

    Set<String?> uniqueIconPaths = widget.places!
        .map((data) => data.imageUrl)
        .where((path) => path != null && path.isNotEmpty)
        .toSet();

    for (String? path in uniqueIconPaths) {
      if (path == null || path.isEmpty) continue;
      
      try {
        Uint8List? imageData = await _loadNetworkImage(path);
        if (imageData != null) {
          _customIcons[path] = await google_maps_flutter.BitmapDescriptor.fromBytes(imageData);
        }
      } catch (e) {
        print('Error loading marker icon: $e');
      }
    }

    _updateMarkers();
  }

  Future<Uint8List?> _loadNetworkImage(String path) async {
    try {
      final completer = Completer<ImageInfo>();
      final image = NetworkImage(path);
      final imageStream = image.resolve(const ImageConfiguration());
      
      imageStream.addListener(ImageStreamListener(
        (ImageInfo info, bool _) {
          if (!completer.isCompleted) {
            completer.complete(info);
          }
        },
        onError: (exception, stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(exception);
          }
        },
      ));
      
      // Timeout para evitar esperas infinitas
      Future.delayed(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Image loading timed out'));
        }
      });
      
      final imageInfo = await completer.future;
      final byteData = await imageInfo.image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error loading network image: $e');
      return null;
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers = _createMarkers();
    });
  }

  void _onMapCreated(google_maps_flutter.GoogleMapController controller) {
    if (_controller != null && !_controller!.isCompleted) {
      _controller!.complete(controller);
    }
  }

  Set<google_maps_flutter.Marker> _createMarkers() {
    var markers = <google_maps_flutter.Marker>{};

    if (widget.places == null) return markers;

    for (int i = 0; i < widget.places!.length; i++) {
      var place = widget.places![i];
      
      // Validar coordenadas
      if (place.latitude == null || place.longitude == null) {
        continue; // Skip invalid coordinates
      }

      // Crear directamente el LatLng de Google Maps
      final position = google_maps_flutter.LatLng(
        place.latitude!, 
        place.longitude!
      );

      // Obtener icono o usar el predeterminado
      final icon = place.imageUrl != null && place.imageUrl!.isNotEmpty
          ? _customIcons[place.imageUrl] ?? google_maps_flutter.BitmapDescriptor.defaultMarker
          : google_maps_flutter.BitmapDescriptor.defaultMarker;

      final marker = google_maps_flutter.Marker(
        markerId: google_maps_flutter.MarkerId('marker_$i'),
        position: position,
        icon: icon,
        onTap: () async {
          await widget.onClickMarker?.call(place);
        },
      );

      markers.add(marker);
    }
    
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return google_maps_flutter.GoogleMap(
      onMapCreated: _onMapCreated,
      zoomGesturesEnabled: widget.allowZoom,
      zoomControlsEnabled: widget.showZoomControls,
      myLocationEnabled: widget.showLocation,
      compassEnabled: widget.showCompass,
      mapToolbarEnabled: widget.showMapToolbar,
      trafficEnabled: widget.showTraffic,
      initialCameraPosition: google_maps_flutter.CameraPosition(
        target: _center,
        zoom: widget.defaultZoom,
      ),
      markers: _markers,
    );
  }
}