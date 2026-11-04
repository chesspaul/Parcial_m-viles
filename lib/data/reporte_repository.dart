import '../models/reporte.dart';

/// Contrato de acceso a datos de los reportes.
///
/// La interfaz depende de esta abstracción (DIP): si mañana se cambia SQLite
/// por SharedPreferences o una API, solo se escribe otra implementación y la
/// UI no se modifica (OCP).
abstract class ReporteRepository {
  Future<List<Reporte>> obtenerTodos();

  Future<int> insertar(Reporte reporte);

  Future<void> actualizarAtendido(int id, bool atendido);

  Future<void> eliminar(int id);
}
