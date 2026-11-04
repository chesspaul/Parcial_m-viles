import 'package:flutter/material.dart';

import '../app/rutas.dart';

/// Menú lateral principal de la app.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onNuevoReporte});

  /// La pantalla de lista decide cómo abrir el formulario (y refrescarse).
  final VoidCallback onNuevoReporte;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: esquema.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.pets, size: 48, color: esquema.onPrimaryContainer),
                const SizedBox(height: 8),
                Text(
                  'Patitas en la calle',
                  style: textos.titleLarge?.copyWith(
                    color: esquema.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Reporta y ubica animales que necesitan ayuda',
                  style: textos.bodySmall?.copyWith(
                    color: esquema.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Reportes'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_a_photo_outlined),
            title: const Text('Nuevo reporte'),
            onTap: () {
              Navigator.pop(context);
              onNuevoReporte();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              final navegador = Navigator.of(context);
              navegador.pop();
              navegador.pushNamed(Rutas.acerca);
            },
          ),
        ],
      ),
    );
  }
}
