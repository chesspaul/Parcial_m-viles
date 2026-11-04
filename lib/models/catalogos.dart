/// Valores permitidos para los campos de un reporte.
const List<String> especies = ['Perro', 'Gato', 'Otro'];

const List<String> estados = [
  'Sano',
  'Herido',
  'Desnutrido',
  'Enfermo',
  'Cachorro',
];

/// Texto para el nivel de urgencia: 1 baja, 2 media, 3 alta.
String etiquetaUrgencia(int urgencia) {
  switch (urgencia) {
    case 1:
      return 'Baja';
    case 2:
      return 'Media';
    default:
      return 'Alta';
  }
}
