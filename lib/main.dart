import 'package:flutter/material.dart';

import 'app/rutas.dart';
import 'app/tema.dart';

void main() {
  runApp(const PatitasApp());
}

/// Raíz de la aplicación: solo configura tema y navegación (SRP).
class PatitasApp extends StatelessWidget {
  const PatitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patitas en la calle',
      debugShowCheckedModeBanner: false,
      theme: AppTema.claro(),
      darkTheme: AppTema.oscuro(),
      themeMode: ThemeMode.system,
      initialRoute: Rutas.lista,
      onGenerateRoute: Rutas.generar,
    );
  }
}
