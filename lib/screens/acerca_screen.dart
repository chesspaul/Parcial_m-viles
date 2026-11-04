import 'package:flutter/material.dart';

/// Pantalla informativa: qué problema resuelve la app.
class AcercaScreen extends StatelessWidget {
  const AcercaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.pets, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Patitas en la calle', style: textos.headlineSmall),
          const SizedBox(height: 16),
          Text('¿Qué problema resuelve?', style: textos.titleMedium),
          const SizedBox(height: 6),
          const Text(
            'Cuando alguien ve un animal herido o abandonado en la calle, rara '
            'vez queda registro de dónde estaba ni en qué condición. Esta app '
            'permite documentar cada caso con foto, descripción dictada o '
            'escrita, nota de voz y coordenadas GPS exactas, para que '
            'rescatistas y albergues puedan encontrarlo y priorizarlo.',
          ),
          const SizedBox(height: 16),
          Text('Cómo funciona', style: textos.titleMedium),
          const SizedBox(height: 6),
          const Text(
            '1. Crea un reporte con foto, estado y nivel de urgencia.\n'
            '2. Al guardar se captura tu ubicación actual.\n'
            '3. Consulta el detalle con mapa interactivo o ábrelo en Google Maps.\n'
            '4. Marca el caso como atendido cuando reciba ayuda.\n'
            '5. Todo se guarda en el dispositivo (SQLite), sin internet.',
          ),
        ],
      ),
    );
  }
}
