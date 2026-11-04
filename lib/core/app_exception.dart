/// Excepción propia de la app con un mensaje entendible para el usuario.
///
/// Las capas inferiores (datos, servicios) capturan los errores técnicos con
/// try-catch y los convierten en [AppException]; la UI solo muestra
/// [mensaje].
class AppException implements Exception {
  AppException(this.mensaje, {this.causa});

  final String mensaje;
  final Object? causa;

  @override
  String toString() =>
      'AppException: $mensaje${causa != null ? ' (causa: $causa)' : ''}';
}

/// Obtiene un texto amigable para cualquier error capturado.
String mensajeDeError(Object error) {
  if (error is AppException) return error.mensaje;
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
