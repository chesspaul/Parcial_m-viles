import '../core/app_exception.dart';
import '../models/reporte.dart';
import 'database_helper.dart';
import 'reporte_repository.dart';

/// Implementación de [ReporteRepository] sobre SQLite.
///
/// Cada operación usa try-catch y traduce los errores técnicos a
/// [AppException] con un mensaje claro.
class SqliteReporteRepository implements ReporteRepository {
  SqliteReporteRepository(this._helper);

  final DatabaseHelper _helper;

  @override
  Future<List<Reporte>> obtenerTodos() async {
    try {
      final db = await _helper.database;
      final filas = await db.query(
        DatabaseHelper.tablaReportes,
        orderBy: 'fecha DESC',
      );
      return filas.map(Reporte.fromMap).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('No se pudieron cargar los reportes.', causa: e);
    }
  }

  @override
  Future<int> insertar(Reporte reporte) async {
    try {
      final db = await _helper.database;
      return await db.insert(DatabaseHelper.tablaReportes, reporte.toMap());
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('No se pudo guardar el reporte.', causa: e);
    }
  }

  @override
  Future<void> actualizarAtendido(int id, bool atendido) async {
    try {
      final db = await _helper.database;
      await db.update(
        DatabaseHelper.tablaReportes,
        {'atendido': atendido ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('No se pudo actualizar el reporte.', causa: e);
    }
  }

  @override
  Future<void> eliminar(int id) async {
    try {
      final db = await _helper.database;
      await db.delete(
        DatabaseHelper.tablaReportes,
        where: 'id = ?',
        whereArgs: [id],
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('No se pudo eliminar el reporte.', causa: e);
    }
  }
}
