import 'package:record/record.dart';

import '../core/app_exception.dart';
import 'archivo_service.dart';

/// Graba una nota de voz (.m4a) en el almacenamiento de la app.
///
/// Es el uso "fundamental" del micrófono: captura el audio y guarda el
/// archivo. La reproducción la hace el widget ReproductorAudio.
class AudioService {
  AudioService(this._archivos);

  final ArchivoService _archivos;
  final AudioRecorder _grabadora = AudioRecorder();

  Future<void> iniciarGrabacion() async {
    try {
      if (!await _grabadora.hasPermission()) {
        throw AppException('Permiso de micrófono denegado.');
      }
      final ruta = await _archivos.rutaNueva(
        subcarpeta: 'audios',
        prefijo: 'nota',
        ext: '.m4a',
      );
      await _grabadora.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: ruta,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('No se pudo iniciar la grabación.', causa: e);
    }
  }

  /// Detiene la grabación y devuelve la ruta del archivo guardado.
  Future<String?> detenerGrabacion() async {
    try {
      return await _grabadora.stop();
    } catch (e) {
      throw AppException('No se pudo detener la grabación.', causa: e);
    }
  }

  /// Libera el micrófono; si había una grabación en curso, la descarta.
  Future<void> dispose() async {
    try {
      if (await _grabadora.isRecording()) {
        await _grabadora.cancel();
      }
      await _grabadora.dispose();
    } catch (_) {
      // Liberación de recursos: ignorar errores.
    }
  }
}
