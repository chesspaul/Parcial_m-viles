import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../core/app_exception.dart';
import 'archivo_service.dart';

/// Origen de la imagen (evita que la UI dependa de image_picker).
enum FuenteImagen { camara, galeria }

/// Toma una foto con la cámara o elige una de la galería y la guarda dentro
/// del almacenamiento de la app.
class ImageService {
  ImageService(this._archivos);

  final ArchivoService _archivos;
  final ImagePicker _picker = ImagePicker();

  /// Devuelve la ruta final de la foto, o null si el usuario canceló.
  Future<String?> obtenerFoto(FuenteImagen fuente) async {
    try {
      final XFile? elegido = await _picker.pickImage(
        source: fuente == FuenteImagen.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (elegido == null) return null;

      final extension = p.extension(elegido.path);
      final destino = await _archivos.rutaNueva(
        subcarpeta: 'fotos',
        prefijo: 'foto',
        ext: extension.isEmpty ? '.jpg' : extension,
      );
      await File(elegido.path).copy(destino);
      // La copia temporal del selector ya no hace falta.
      await _archivos.borrarSilencioso(elegido.path);
      return destino;
    } catch (e) {
      throw AppException(
        'No se pudo obtener la foto. Revisa los permisos de la cámara.',
        causa: e,
      );
    }
  }
}
