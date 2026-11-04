import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../core/formato.dart';

/// Reproduce una nota de voz guardada en un archivo local.
class ReproductorAudio extends StatefulWidget {
  const ReproductorAudio({super.key, required this.ruta});

  final String ruta;

  @override
  State<ReproductorAudio> createState() => _ReproductorAudioState();
}

class _ReproductorAudioState extends State<ReproductorAudio> {
  final AudioPlayer _reproductor = AudioPlayer();
  final List<StreamSubscription<dynamic>> _suscripciones = [];

  PlayerState _estado = PlayerState.stopped;
  Duration _posicion = Duration.zero;
  Duration _duracion = Duration.zero;

  @override
  void initState() {
    super.initState();
    _suscripciones.addAll([
      _reproductor.onPlayerStateChanged.listen((estado) {
        if (mounted) setState(() => _estado = estado);
      }),
      _reproductor.onPositionChanged.listen((posicion) {
        if (mounted) setState(() => _posicion = posicion);
      }),
      _reproductor.onDurationChanged.listen((duracion) {
        if (mounted) setState(() => _duracion = duracion);
      }),
      _reproductor.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _posicion = Duration.zero);
      }),
    ]);
  }

  Future<void> _alternar() async {
    try {
      if (_estado == PlayerState.playing) {
        await _reproductor.pause();
      } else if (_estado == PlayerState.paused) {
        await _reproductor.resume();
      } else {
        await _reproductor.play(DeviceFileSource(widget.ruta));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo reproducir la nota de voz.')),
      );
    }
  }

  @override
  void dispose() {
    for (final suscripcion in _suscripciones) {
      suscripcion.cancel();
    }
    _reproductor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final reproduciendo = _estado == PlayerState.playing;
    final progreso = _duracion.inMilliseconds == 0
        ? 0.0
        : (_posicion.inMilliseconds / _duracion.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: _alternar,
            tooltip: reproduciendo ? 'Pausar' : 'Reproducir',
            icon: Icon(reproduciendo ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: progreso),
                const SizedBox(height: 4),
                Text(
                  '${formatearDuracion(_posicion)} / ${formatearDuracion(_duracion)}',
                  style: textos.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
