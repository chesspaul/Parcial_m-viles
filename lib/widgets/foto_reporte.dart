import 'dart:io';

import 'package:flutter/material.dart';

/// Muestra la foto de un reporte desde un archivo local.
/// Si no hay foto o el archivo ya no existe, muestra un marcador.
class FotoReporte extends StatelessWidget {
  const FotoReporte({
    super.key,
    required this.ruta,
    this.ancho,
    this.alto,
    this.cacheAncho,
  });

  final String? ruta;
  final double? ancho;
  final double? alto;

  /// Ancho de decodificación (ahorra memoria en miniaturas).
  final int? cacheAncho;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final marcador = Container(
      width: ancho,
      height: alto,
      color: esquema.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.pets, size: 36, color: esquema.onSurfaceVariant),
    );

    final r = ruta;
    if (r == null) return marcador;

    return Image.file(
      File(r),
      width: ancho,
      height: alto,
      fit: BoxFit.cover,
      cacheWidth: cacheAncho,
      errorBuilder: (context, error, stackTrace) => marcador,
    );
  }
}
