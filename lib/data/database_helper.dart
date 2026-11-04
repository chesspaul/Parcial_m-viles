import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/app_exception.dart';

/// Abre y crea la base de datos SQLite (Singleton).
///
/// Solo se encarga de la conexión y del esquema; las consultas viven en el
/// repositorio (SRP).
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _nombreDb = 'patitas.db';
  static const int _version = 1;
  static const String tablaReportes = 'reportes';

  Database? _db;

  Future<Database> get database async {
    final existente = _db;
    if (existente != null) return existente;
    try {
      final ruta = p.join(await getDatabasesPath(), _nombreDb);
      final abierta = await openDatabase(
        ruta,
        version: _version,
        onCreate: _crearTablas,
      );
      _db = abierta;
      return abierta;
    } catch (e) {
      throw AppException('No se pudo abrir la base de datos local.', causa: e);
    }
  }

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaReportes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        especie TEXT NOT NULL,
        estado TEXT NOT NULL,
        urgencia INTEGER NOT NULL,
        descripcion TEXT NOT NULL,
        ruta_imagen TEXT,
        ruta_audio TEXT,
        latitud REAL NOT NULL,
        longitud REAL NOT NULL,
        fecha INTEGER NOT NULL,
        atendido INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
