import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mapa interactivo (OpenStreetMap) con un marcador en la ubicación guardada.
/// No requiere API key.
class MapaUbicacion extends StatelessWidget {
  const MapaUbicacion({
    super.key,
    required this.latitud,
    required this.longitud,
    this.alto = 240,
  });

  final double latitud;
  final double longitud;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final punto = LatLng(latitud, longitud);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: alto,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: punto,
            initialZoom: 16,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.patitas_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: punto,
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on,
                    size: 48,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
