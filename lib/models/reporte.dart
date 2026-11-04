/// Un reporte de un animal en situación de calle (entrada del "diario").
///
/// Es un objeto inmutable que sabe convertirse desde/hacia el mapa que
/// guarda SQLite. No conoce la base de datos ni la interfaz (SRP).
class Reporte {
  const Reporte({
    this.id,
    required this.especie,
    required this.estado,
    required this.urgencia,
    required this.descripcion,
    this.rutaImagen,
    this.rutaAudio,
    required this.latitud,
    required this.longitud,
    required this.fecha,
    this.atendido = false,
  });

  final int? id;
  final String especie;
  final String estado;

  /// 1 baja, 2 media, 3 alta.
  final int urgencia;
  final String descripcion;

  /// Ruta de la foto dentro del almacenamiento de la app.
  final String? rutaImagen;

  /// Ruta de la nota de voz dentro del almacenamiento de la app.
  final String? rutaAudio;
  final double latitud;
  final double longitud;
  final DateTime fecha;
  final bool atendido;

  Reporte copyWith({bool? atendido}) {
    return Reporte(
      id: id,
      especie: especie,
      estado: estado,
      urgencia: urgencia,
      descripcion: descripcion,
      rutaImagen: rutaImagen,
      rutaAudio: rutaAudio,
      latitud: latitud,
      longitud: longitud,
      fecha: fecha,
      atendido: atendido ?? this.atendido,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'especie': especie,
      'estado': estado,
      'urgencia': urgencia,
      'descripcion': descripcion,
      'ruta_imagen': rutaImagen,
      'ruta_audio': rutaAudio,
      'latitud': latitud,
      'longitud': longitud,
      'fecha': fecha.millisecondsSinceEpoch,
      'atendido': atendido ? 1 : 0,
    };
  }

  factory Reporte.fromMap(Map<String, Object?> mapa) {
    return Reporte(
      id: mapa['id'] as int?,
      especie: mapa['especie'] as String,
      estado: mapa['estado'] as String,
      urgencia: mapa['urgencia'] as int,
      descripcion: mapa['descripcion'] as String,
      rutaImagen: mapa['ruta_imagen'] as String?,
      rutaAudio: mapa['ruta_audio'] as String?,
      latitud: (mapa['latitud'] as num).toDouble(),
      longitud: (mapa['longitud'] as num).toDouble(),
      fecha: DateTime.fromMillisecondsSinceEpoch(mapa['fecha'] as int),
      atendido: (mapa['atendido'] as int) == 1,
    );
  }
}
