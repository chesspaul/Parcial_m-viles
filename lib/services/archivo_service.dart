import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Gestiona los archivos propios de la app (fotos y audios).
///
/// Las fotos de la cámara llegan a una carpeta temporal que el sistema puede
/// limpiar; por eso se copian aquí y en SQLite solo se guarda la ruta.
class ArchivoService {
  /// Devuelve una ruta nueva y única dentro de [subcarpeta] (se crea si no
  /// existe). Ejemplo: .../fotos/foto_1730000000000.jpg
  Future<String> rutaNueva({
    required String subcarpeta,
    required String prefijo,
    required String ext,
  }) async {
    final base = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(base.path, subcarpeta));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    final marca = DateTime.now().millisecondsSinceEpoch;
    return p.join(carpeta.path, '${prefijo}_$marca$ext');
  }

  /// Borra un archivo si existe; nunca lanza error (es limpieza).
  Future<void> borrarSilencioso(String? ruta) async {
    if (ruta == null) return;
    try {
      final archivo = File(ruta);
      if (await archivo.exists()) {
        await archivo.delete();
      }
    } catch (_) {
      // Limpieza de mejor esfuerzo: ignorar.
    }
  }
}
