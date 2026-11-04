import 'package:speech_to_text/speech_to_text.dart';

import '../core/app_exception.dart';

/// Dictado: convierte la voz del usuario en texto (speech_to_text).
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _inicializado = false;
  String? _idioma;

  /// Prepara el reconocimiento. Devuelve false si el dispositivo no lo
  /// soporta o el usuario negó el permiso del micrófono.
  Future<bool> inicializar({
    void Function(String estado)? onEstado,
    void Function(String error)? onError,
  }) async {
    if (_inicializado) return true;
    try {
      _inicializado = await _speech.initialize(
        onStatus: (estado) => onEstado?.call(estado),
        onError: (error) => onError?.call(error.errorMsg),
      );
      if (_inicializado) {
        await _elegirIdioma();
      }
      return _inicializado;
    } catch (e) {
      throw AppException(
        'No se pudo iniciar el reconocimiento de voz.',
        causa: e,
      );
    }
  }

  Future<void> _elegirIdioma() async {
    final idiomas = await _speech.locales();
    for (final idioma in idiomas) {
      if (idioma.localeId == 'es_MX' || idioma.localeId == 'es-MX') {
        _idioma = idioma.localeId;
        return;
      }
    }
    final sistema = await _speech.systemLocale();
    _idioma = sistema?.localeId;
  }

  /// Empieza a escuchar; [onTexto] recibe el texto reconocido hasta el momento.
  Future<void> escuchar(void Function(String texto) onTexto) async {
    try {
      await _speech.listen(
        localeId: _idioma,
        onResult: (resultado) => onTexto(resultado.recognizedWords),
      );
    } catch (e) {
      throw AppException('No se pudo iniciar el dictado.', causa: e);
    }
  }

  Future<void> detener() async {
    try {
      await _speech.stop();
    } catch (_) {
      // Ignorar: ya estaba detenido.
    }
  }

  Future<void> cancelar() async {
    try {
      await _speech.cancel();
    } catch (_) {
      // Ignorar.
    }
  }
}
