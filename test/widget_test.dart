import 'package:flutter_test/flutter_test.dart';
import 'package:patitas_app/models/reporte.dart';

void main() {
  test('Reporte se convierte a mapa y de vuelta sin perder datos', () {
    final original = Reporte(
      id: 1,
      especie: 'Perro',
      estado: 'Herido',
      urgencia: 3,
      descripcion: 'Cojea de la pata derecha',
      rutaImagen: '/fotos/foto_1.jpg',
      rutaAudio: '/audios/nota_1.m4a',
      latitud: 19.4326,
      longitud: -99.1332,
      fecha: DateTime.fromMillisecondsSinceEpoch(1730000000000),
      atendido: true,
    );

    final copia = Reporte.fromMap(original.toMap());

    expect(copia.id, 1);
    expect(copia.especie, 'Perro');
    expect(copia.urgencia, 3);
    expect(copia.rutaAudio, '/audios/nota_1.m4a');
    expect(copia.latitud, 19.4326);
    expect(copia.fecha, original.fecha);
    expect(copia.atendido, isTrue);
  });

  test('copyWith solo cambia el estado de atención', () {
    final reporte = Reporte(
      especie: 'Gato',
      estado: 'Sano',
      urgencia: 1,
      descripcion: 'Duerme bajo un coche',
      latitud: 0,
      longitud: 0,
      fecha: DateTime.fromMillisecondsSinceEpoch(0),
    );

    final atendido = reporte.copyWith(atendido: true);

    expect(reporte.atendido, isFalse);
    expect(atendido.atendido, isTrue);
    expect(atendido.especie, 'Gato');
  });
}
