import 'package:flutter/material.dart';

/// Tema visual de la app (claro y oscuro) y colores semánticos.
class AppTema {
  AppTema._();

  static const Color _semilla = Color(0xFFE07A2F);

  static ThemeData claro() => _construir(Brightness.light);

  static ThemeData oscuro() => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _semilla,
        brightness: brillo,
      ),
    );
  }

  /// Color por nivel de urgencia: 1 baja, 2 media, 3 alta.
  static Color colorUrgencia(int urgencia) {
    switch (urgencia) {
      case 1:
        return const Color(0xFF2E7D32);
      case 2:
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFFC62828);
    }
  }
}
