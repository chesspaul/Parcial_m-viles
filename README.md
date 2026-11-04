# Patitas en la calle

App móvil en Flutter para **reportar animales en situación de calle**: cada reporte
se documenta con foto, descripción (escrita o dictada), nota de voz y ubicación GPS,
y se guarda en el dispositivo.

**Autor:** Paul Rosales · Proyecto individual de desarrollo móvil (Flutter / Dart)

## ¿Qué problema resuelve?

Cuando alguien encuentra un animal herido o abandonado en la calle, casi nunca queda
registro de **dónde estaba** ni **en qué condición**. Patitas permite documentar cada caso
con evidencia y coordenadas exactas, para que rescatistas y albergues puedan encontrarlo
y priorizarlo por nivel de urgencia.

## Funciones

- **Lista de reportes** con foto, especie, estado, urgencia y fecha.
- **Nuevo reporte**:
    - Foto con la **cámara** o desde la **galería**.
    - Descripción escrita o **dictada por voz** (voz a texto).
    - **Nota de voz** grabada y guardada, con reproductor.
    - **Ubicación GPS** capturada automáticamente al guardar.
- **Detalle** con animación **Hero** en la foto, nota de voz, **mapa interactivo**
  (OpenStreetMap) y botón para abrir la ubicación en **Google Maps**.
- Marcar un reporte como **atendido** y eliminarlo.
- Todo se guarda **localmente** en SQLite; funciona sin cuenta ni servidor.

## Tecnologías

| Área | Paquete |
|---|---|
| Base de datos local | `sqflite`, `path`, `path_provider` |
| Cámara y galería | `image_picker` |
| Nota de voz | `record`, `audioplayers` |
| Dictado | `speech_to_text` |
| GPS | `geolocator` |
| Mapa interactivo | `flutter_map`, `latlong2` (OpenStreetMap, sin API key) |
| Abrir Google Maps | `url_launcher` |

Manejo de estado: `setState` + `FutureBuilder`.

## Arquitectura

El código está organizado por capas, siguiendo principios SOLID:

```
lib/
├── main.dart                  Arranque de la app
├── app/                       Rutas (Navigator), tema e inyección de dependencias
├── core/                      Excepciones propias y utilidades de formato
├── models/                    Reporte, catálogos y coordenadas
├── data/                      SQLite: DatabaseHelper + repositorio (interfaz e implementación)
├── services/                  Cámara, audio, dictado, GPS, mapas y archivos
├── screens/                   Lista, detalle, formulario y "Acerca de"
└── widgets/                   Tarjeta, drawer, mapa, reproductor y foto
```

- **S** — Cada clase tiene una sola responsabilidad (`DatabaseHelper` conecta, el repositorio consulta, `ArchivoService` gestiona archivos).
- **O / L** — `ReporteRepository` es una interfaz; se puede reemplazar SQLite por otra fuente sin tocar la interfaz de usuario.
- **I** — La interfaz del repositorio es pequeña (4 métodos).
- **D** — Las pantallas dependen de abstracciones y reciben sus dependencias desde `app/inyector.dart`.

**Flujo de datos al guardar un reporte:**
Formulario → foto / audio / dictado → `LocationService` (GPS) → `Reporte` → `ReporteRepository.insertar` → SQLite → Lista (`FutureBuilder`) → Detalle.

Las fotos y los audios se copian al almacenamiento de la app; en la base de datos solo se guardan sus **rutas** y las coordenadas.

**Manejo de errores:** los servicios y el repositorio usan `try-catch` y convierten los fallos técnicos en `AppException` con un mensaje claro para el usuario (GPS apagado, permiso denegado, etc.).

## Cómo ejecutarla

Requisitos: Flutter 3.47 o superior (Dart 3.13), Android Studio y un dispositivo o emulador Android (API 23+).

```bash
git clone https://github.com/chesspaul/Parcial_m-viles.git
cd Parcial_m-viles
flutter pub get
flutter run
```

Pruebas unitarias:

```bash
flutter test
```

### Notas para probarla

- Activa el **GPS** del dispositivo; el mapa necesita **internet** para descargar los mosaicos.
- El **dictado** requiere el servicio de voz de Google instalado y el permiso de micrófono.
- La app pide permisos de **ubicación** y **micrófono** en ejecución. La cámara se abre mediante la app de cámara del sistema.
- Probada en un **Honor X8b con Android 14**.