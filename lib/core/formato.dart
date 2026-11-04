/// Utilidades de formato (sin dependencias externas).

String _dosDigitos(int n) => n.toString().padLeft(2, '0');

/// dd/mm/aaaa hh:mm
String formatearFecha(DateTime fecha) {
  return '${_dosDigitos(fecha.day)}/${_dosDigitos(fecha.month)}/${fecha.year} '
      '${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';
}

/// mm:ss
String formatearDuracion(Duration duracion) {
  return '${_dosDigitos(duracion.inMinutes)}:'
      '${_dosDigitos(duracion.inSeconds.remainder(60))}';
}
