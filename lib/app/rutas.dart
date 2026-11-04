import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../screens/acerca_screen.dart';
import '../screens/detalle_screen.dart';
import '../screens/formulario_screen.dart';
import '../screens/lista_screen.dart';

/// Nombres de ruta y fábrica de rutas con transiciones animadas.
///
/// Centraliza la navegación: las pantallas solo conocen el nombre de la
/// ruta, no la clase concreta de la pantalla destino.
class Rutas {
  Rutas._();

  static const String lista = '/';
  static const String detalle = '/detalle';
  static const String nueva = '/nueva';
  static const String acerca = '/acerca';

  static Route<dynamic> generar(RouteSettings settings) {
    switch (settings.name) {
      case lista:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const ListaScreen(),
        );
      case detalle:
        final argumento = settings.arguments;
        if (argumento is! Reporte) {
          return _rutaNoEncontrada(settings);
        }
        // Fundido suave: permite ver la animación Hero de la foto.
        return _fundido(DetalleScreen(reporte: argumento), settings);
      case nueva:
        return _deslizarDesdeAbajo(const FormularioScreen(), settings);
      case acerca:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const AcercaScreen(),
        );
      default:
        return _rutaNoEncontrada(settings);
    }
  }

  static Route<T> _fundido<T>(Widget pagina, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  static Route<T> _deslizarDesdeAbajo<T>(Widget pagina, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final desplazamiento = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(desplazamiento),
          child: child,
        );
      },
    );
  }

  static Route<dynamic> _rutaNoEncontrada(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Ruta no encontrada')),
        body: const Center(child: Text('La pantalla solicitada no existe.')),
      ),
    );
  }
}
