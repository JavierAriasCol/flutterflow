List<PantallaCoordenadaStruct> doubleToLatLong(
    List<PantallaDoubleStruct> pantallasDouble) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  return pantallasDouble.map((pantallaDouble) {
    return PantallaCoordenadaStruct(
      pantallaId: pantallaDouble.pantallaId,
      peliculaId: pantallaDouble.peliculaId,
      lugarId: pantallaDouble.lugarId,
      imageUrl: pantallaDouble.imageUrl,
      coordenada: LatLng(pantallaDouble.latitude, pantallaDouble.longitude),
    );
  }).toList();

  /// MODIFY CODE ONLY ABOVE THIS LINE
}