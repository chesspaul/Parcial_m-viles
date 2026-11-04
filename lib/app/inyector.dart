import '../data/database_helper.dart';
import '../data/reporte_repository.dart';
import '../data/sqlite_reporte_repository.dart';
import '../services/archivo_service.dart';
import '../services/audio_service.dart';
import '../services/image_service.dart';
import '../services/location_service.dart';
import '../services/maps_launcher.dart';
import '../services/speech_service.dart';

/// Punto único donde se construyen las dependencias (inversión de
/// dependencias): las pantallas piden abstracciones/servicios aquí y no
/// crean sus propias implementaciones concretas.
class Inyector {
  Inyector._();

  static final ArchivoService archivoService = ArchivoService();

  /// La UI depende de la abstracción [ReporteRepository], no de SQLite.
  static final ReporteRepository reporteRepository =
      SqliteReporteRepository(DatabaseHelper.instance);

  static final ImageService imageService = ImageService(archivoService);
  static final LocationService locationService = LocationService();
  static final MapsLauncher mapsLauncher = MapsLauncher();

  /// El micrófono es un recurso exclusivo: cada pantalla crea el suyo.
  static AudioService crearAudioService() => AudioService(archivoService);

  static SpeechService crearSpeechService() => SpeechService();
}
