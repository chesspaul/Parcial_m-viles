import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../core/formato.dart';
import '../models/catalogos.dart';
import '../models/reporte.dart';
import 'foto_reporte.dart';

/// Tarjeta de un reporte en la lista. La foto lleva un [Hero] que vuela
/// hacia la pantalla de detalle.
class ReporteCard extends StatelessWidget {
  const ReporteCard({super.key, required this.reporte, required this.onTap});

  final Reporte reporte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'foto-${reporte.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FotoReporte(
                    ruta: reporte.rutaImagen,
                    ancho: 92,
                    alto: 92,
                    cacheAncho: 300,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${reporte.especie} · ${reporte.estado}',
                            style: textos.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (reporte.atendido)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reporte.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: AppTema.colorUrgencia(reporte.urgencia),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Urgencia ${etiquetaUrgencia(reporte.urgencia).toLowerCase()}',
                          style: textos.labelSmall,
                        ),
                        const Spacer(),
                        Text(formatearFecha(reporte.fecha), style: textos.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
