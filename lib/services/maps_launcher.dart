import 'package:url_launcher/url_launcher.dart';

import '../core/app_exception.dart';

/// Abre una ubicación en la app externa de mapas (Google Maps).
class MapsLauncher {
  Future<void> abrirEnMapas(double latitud, double longitud) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud',
    );
    try {
      final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abierto) {
        throw AppException('No se encontró una app para abrir el mapa.');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('No se pudo abrir Google Maps.', causa: e);
    }
  }
}
