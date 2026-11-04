import 'package:flutter/material.dart';

import '../app/inyector.dart';
import '../app/tema.dart';
import '../core/app_exception.dart';
import '../core/formato.dart';
import '../models/catalogos.dart';
import '../models/reporte.dart';
import '../widgets/foto_reporte.dart';
import '../widgets/mapa_ubicacion.dart';
import '../widgets/reproductor_audio.dart';

/// Detalle de un reporte: foto (Hero), datos, nota de voz y mapa.
class DetalleScreen extends StatefulWidget {
  const DetalleScreen({super.key, required this.reporte});

  final Reporte reporte;

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _repositorio = Inyector.reporteRepository;
  final _archivos = Inyector.archivoService;
  final _mapas = Inyector.mapsLauncher;

  late Reporte _reporte;

  @override
  void initState() {
    super.initState();
    _reporte = widget.reporte;
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    final mensajero = ScaffoldMessenger.of(context);
    mensajero.hideCurrentSnackBar();
    mensajero.showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _alternarAtendido() async {
    final nuevoValor = !_reporte.atendido;
    try {
      await _repositorio.actualizarAtendido(_reporte.id!, nuevoValor);
      if (!mounted) return;
      setState(() {
        _reporte = _reporte.copyWith(atendido: nuevoValor);
      });
      _aviso(nuevoValor ? 'Marcado como atendido' : 'Marcado como pendiente');
    } catch (e) {
      _aviso(mensajeDeError(e));
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('¿Eliminar reporte?'),
        content: const Text('Se borrarán también la foto y la nota de voz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _repositorio.eliminar(_reporte.id!);
      await _archivos.borrarSilencioso(_reporte.rutaImagen);
      await _archivos.borrarSilencioso(_reporte.rutaAudio);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _aviso(mensajeDeError(e));
    }
  }

  Future<void> _abrirEnGoogleMaps() async {
    try {
      await _mapas.abrirEnMapas(_reporte.latitud, _reporte.longitud);
    } catch (e) {
      _aviso(mensajeDeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporte = _reporte;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${reporte.especie} · ${reporte.estado}'),
        actions: [
          IconButton(
            tooltip: reporte.atendido
                ? 'Marcar como pendiente'
                : 'Marcar como atendido',
            icon: Icon(
              reporte.atendido ? Icons.undo : Icons.check_circle_outline,
            ),
            onPressed: _alternarAtendido,
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete_outline),
            onPressed: _eliminar,
          ),
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'foto-${reporte.id}',
            child: FotoReporte(
              ruta: reporte.rutaImagen,
              ancho: double.infinity,
              alto: 280,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(label: Text(reporte.especie)),
                    Chip(label: Text(reporte.estado)),
                    Chip(
                      avatar: Icon(
                        Icons.circle,
                        size: 14,
                        color: AppTema.colorUrgencia(reporte.urgencia),
                      ),
                      label: Text(
                        'Urgencia ${etiquetaUrgencia(reporte.urgencia).toLowerCase()}',
                      ),
                    ),
                    if (reporte.atendido)
                      const Chip(
                        avatar: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        label: Text('Atendido'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18),
                    const SizedBox(width: 6),
                    Text(formatearFecha(reporte.fecha)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Descripción', style: textos.titleMedium),
                const SizedBox(height: 6),
                Text(reporte.descripcion),
                if (reporte.rutaAudio != null) ...[
                  const SizedBox(height: 20),
                  Text('Nota de voz', style: textos.titleMedium),
                  const SizedBox(height: 8),
                  ReproductorAudio(ruta: reporte.rutaAudio!),
                ],
                const SizedBox(height: 20),
                Text('Ubicación', style: textos.titleMedium),
                const SizedBox(height: 8),
                MapaUbicacion(
                  latitud: reporte.latitud,
                  longitud: reporte.longitud,
                ),
                const SizedBox(height: 8),
                Text(
                  '${reporte.latitud.toStringAsFixed(5)}, '
                  '${reporte.longitud.toStringAsFixed(5)}',
                  style: textos.bodySmall,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _abrirEnGoogleMaps,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Abrir en Google Maps'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
