import 'package:flutter/material.dart';

import '../app/inyector.dart';
import '../app/tema.dart';
import '../core/app_exception.dart';
import '../models/catalogos.dart';
import '../models/reporte.dart';
import '../services/audio_service.dart';
import '../services/image_service.dart';
import '../services/speech_service.dart';
import '../widgets/foto_reporte.dart';
import '../widgets/reproductor_audio.dart';

/// Formulario de nuevo reporte: foto, descripción (con dictado), nota de voz
/// y ubicación GPS (se captura al guardar).
class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();

  final _repositorio = Inyector.reporteRepository;
  final _imagenes = Inyector.imageService;
  final _ubicacion = Inyector.locationService;
  final _archivos = Inyector.archivoService;
  final AudioService _audio = Inyector.crearAudioService();
  final SpeechService _voz = Inyector.crearSpeechService();

  String _especie = especies.first;
  String _estado = estados.first;
  int _urgencia = 2;
  String? _rutaImagen;
  String? _rutaAudio;

  bool _grabando = false;
  bool _dictando = false;
  bool _guardando = false;
  bool _guardado = false;

  /// Texto que ya existía en la descripción cuando empezó el dictado.
  String _textoBase = '';

  void _aviso(String mensaje) {
    if (!mounted) return;
    final mensajero = ScaffoldMessenger.of(context);
    mensajero.hideCurrentSnackBar();
    mensajero.showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ---------------------------------------------------------------- Foto

  Future<void> _elegirFoto(FuenteImagen fuente) async {
    try {
      final ruta = await _imagenes.obtenerFoto(fuente);
      if (ruta == null || !mounted) return;
      await _archivos.borrarSilencioso(_rutaImagen);
      setState(() => _rutaImagen = ruta);
    } catch (e) {
      _aviso(mensajeDeError(e));
    }
  }

  // -------------------------------------------------------------- Dictado

  Future<void> _alternarDictado() async {
    if (_grabando) {
      _aviso('Detén la nota de voz antes de dictar.');
      return;
    }
    if (_dictando) {
      await _voz.detener();
      if (mounted) setState(() => _dictando = false);
      return;
    }
    try {
      final disponible = await _voz.inicializar(
        onEstado: (estado) {
          if ((estado == 'done' || estado == 'notListening') && mounted) {
            setState(() => _dictando = false);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() => _dictando = false);
          final silencio =
              error.contains('no_match') || error.contains('timeout');
          if (!silencio) _aviso('Error de dictado: $error');
        },
      );
      if (!disponible) {
        _aviso(
          'El dictado no está disponible. Revisa el permiso del micrófono y '
          'que el servicio de voz de Google esté instalado.',
        );
        return;
      }
      _textoBase = _descripcionCtrl.text.trim();
      setState(() => _dictando = true);
      await _voz.escuchar((texto) {
        if (!mounted) return;
        final completo = _textoBase.isEmpty ? texto : '$_textoBase $texto';
        setState(() {
          _descripcionCtrl.text = completo;
          _descripcionCtrl.selection =
              TextSelection.collapsed(offset: completo.length);
        });
      });
    } catch (e) {
      if (mounted) setState(() => _dictando = false);
      _aviso(mensajeDeError(e));
    }
  }

  // ----------------------------------------------------------- Nota de voz

  Future<void> _alternarGrabacion() async {
    if (_dictando) {
      _aviso('Termina el dictado antes de grabar una nota de voz.');
      return;
    }
    try {
      if (_grabando) {
        final ruta = await _audio.detenerGrabacion();
        if (!mounted) return;
        setState(() {
          _grabando = false;
          if (ruta != null) _rutaAudio = ruta;
        });
      } else {
        await _archivos.borrarSilencioso(_rutaAudio);
        await _audio.iniciarGrabacion();
        if (!mounted) return;
        setState(() {
          _grabando = true;
          _rutaAudio = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _grabando = false);
      _aviso(mensajeDeError(e));
    }
  }

  // --------------------------------------------------------------- Guardar

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rutaImagen == null) {
      _aviso('Agrega una foto como evidencia.');
      return;
    }
    if (_grabando) {
      _aviso('Detén la grabación antes de guardar.');
      return;
    }
    if (_dictando) {
      await _voz.detener();
    }

    setState(() => _guardando = true);
    try {
      // Requisito: capturar el GPS actual al guardar el reporte.
      final coordenadas = await _ubicacion.obtenerPosicionActual();

      final reporte = Reporte(
        especie: _especie,
        estado: _estado,
        urgencia: _urgencia,
        descripcion: _descripcionCtrl.text.trim(),
        rutaImagen: _rutaImagen,
        rutaAudio: _rutaAudio,
        latitud: coordenadas.latitud,
        longitud: coordenadas.longitud,
        fecha: DateTime.now(),
      );
      await _repositorio.insertar(reporte);

      _guardado = true;
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _guardando = false);
      _aviso(mensajeDeError(e));
    }
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _voz.cancelar();
    _audio.dispose();
    if (!_guardado) {
      // Salió sin guardar: no dejar archivos huérfanos.
      _archivos.borrarSilencioso(_rutaImagen);
      _archivos.borrarSilencioso(_rutaAudio);
    }
    super.dispose();
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo reporte')),
      body: IgnorePointer(
        ignoring: _guardando,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Foto', style: textos.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _rutaImagen == null
                      ? Container(
                          color: esquema.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Text('Sin foto'),
                        )
                      : FotoReporte(
                          ruta: _rutaImagen,
                          ancho: double.infinity,
                          alto: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _elegirFoto(FuenteImagen.camara),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Cámara'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _elegirFoto(FuenteImagen.galeria),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galería'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Animal', style: textos.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  for (final e in especies)
                    ButtonSegment<String>(value: e, label: Text(e)),
                ],
                selected: {_especie},
                onSelectionChanged: (seleccion) =>
                    setState(() => _especie = seleccion.first),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in estados)
                    ChoiceChip(
                      label: Text(e),
                      selected: _estado == e,
                      onSelected: (_) => setState(() => _estado = e),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Urgencia', style: textos.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  for (final nivel in [1, 2, 3])
                    ButtonSegment<int>(
                      value: nivel,
                      label: Text(etiquetaUrgencia(nivel)),
                      icon: Icon(
                        Icons.circle,
                        size: 12,
                        color: AppTema.colorUrgencia(nivel),
                      ),
                    ),
                ],
                selected: {_urgencia},
                onSelectionChanged: (seleccion) =>
                    setState(() => _urgencia = seleccion.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descripcionCtrl,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Dónde está, cómo se ve, qué necesita...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _dictando ? 'Detener dictado' : 'Dictar',
                    icon: Icon(_dictando ? Icons.mic : Icons.mic_none),
                    color: _dictando ? esquema.error : null,
                    onPressed: _alternarDictado,
                  ),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().length < 5) {
                    return 'Escribe o dicta al menos 5 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Nota de voz', style: textos.titleMedium),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: _alternarGrabacion,
                icon: Icon(
                  _grabando ? Icons.stop : Icons.fiber_manual_record,
                  color: _grabando ? esquema.error : null,
                ),
                label: Text(_grabando ? 'Detener grabación' : 'Grabar nota de voz'),
              ),
              if (_rutaAudio != null) ...[
                const SizedBox(height: 8),
                ReproductorAudio(key: ValueKey(_rutaAudio), ruta: _rutaAudio!),
              ],
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, color: esquema.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'La ubicación GPS se captura automáticamente al '
                          'guardar el reporte.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_guardando ? 'Guardando...' : 'Guardar reporte'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
