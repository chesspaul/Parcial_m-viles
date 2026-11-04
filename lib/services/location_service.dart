import 'package:geolocator/geolocator.dart';

import '../core/app_exception.dart';
import '../models/coordenadas.dart';

/// Obtiene la posición GPS actual del dispositivo.
class LocationService {
  Future<Coordenadas> obtenerPosicionActual() async {
    try {
      final gpsActivo = await Geolocator.isLocationServiceEnabled();
      if (!gpsActivo) {
        throw AppException(
          'El GPS está apagado. Actívalo para guardar la ubicación del reporte.',
        );
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied) {
        throw AppException('Se necesita permiso de ubicación para guardar el reporte.');
      }
      if (permiso == LocationPermission.deniedForever) {
        throw AppException(
          'El permiso de ubicación está bloqueado. Actívalo en los ajustes de la app.',
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return Coordenadas(posicion.latitude, posicion.longitude);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        'No se pudo obtener la ubicación. Intenta de nuevo con mejor señal GPS.',
        causa: e,
      );
    }
  }
}
