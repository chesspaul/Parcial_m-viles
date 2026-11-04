import 'package:flutter/material.dart';

import '../app/inyector.dart';
import '../app/rutas.dart';
import '../core/app_exception.dart';
import '../data/reporte_repository.dart';
import '../models/reporte.dart';
import '../widgets/app_drawer.dart';
import '../widgets/reporte_card.dart';

/// Pantalla principal: lista de reportes guardados (FutureBuilder).
class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final ReporteRepository _repositorio = Inyector.reporteRepository;

  late Future<List<Reporte>> _futuro;

  /// Últimos datos mostrados: evitan que la lista parpadee al recargar
  /// (y mantienen el destino de la animación Hero al volver del detalle).
  List<Reporte>? _ultimos;

  @override
  void initState() {
    super.initState();
    _futuro = _repositorio.obtenerTodos();
  }

  void _recargar() {
    setState(() {
      _futuro = _repositorio.obtenerTodos();
    });
  }

  Future<void> _refrescar() async {
    _recargar();
    try {
      await _futuro;
    } catch (_) {
      // El FutureBuilder ya muestra el error.
    }
  }

  Future<void> _abrirFormulario() async {
    await Navigator.pushNamed(context, Rutas.nueva);
    if (mounted) _recargar();
  }

  Future<void> _abrirDetalle(Reporte reporte) async {
    await Navigator.pushNamed(context, Rutas.detalle, arguments: reporte);
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patitas en la calle'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
          ),
        ],
      ),
      drawer: AppDrawer(onNuevoReporte: _abrirFormulario),
      body: FutureBuilder<List<Reporte>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _VistaError(
              mensaje: mensajeDeError(snapshot.error!),
              onReintentar: _recargar,
            );
          }
          final datos = snapshot.data ?? _ultimos;
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _ultimos = datos;

          return RefreshIndicator(
            onRefresh: _refrescar,
            child: datos.isEmpty
                ? const _VistaVacia()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 96),
                    itemCount: datos.length,
                    itemBuilder: (context, indice) {
                      final reporte = datos[indice];
                      return ReporteCard(
                        reporte: reporte,
                        onTap: () => _abrirDetalle(reporte),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Nuevo reporte'),
      ),
    );
  }
}

class _VistaVacia extends StatelessWidget {
  const _VistaVacia();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    // ListView para que el "jalar para actualizar" funcione también vacío.
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 96),
        Icon(Icons.pets, size: 72, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Aún no hay reportes',
          textAlign: TextAlign.center,
          style: textos.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Toca "Nuevo reporte" para registrar un animal que necesite ayuda, '
          'con foto, nota de voz y ubicación.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VistaError extends StatelessWidget {
  const _VistaError({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
