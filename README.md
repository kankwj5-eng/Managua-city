# Ciudad del Lago

**Ciudad del Lago** es una vertical slice original de acción y conducción en tercera persona para Android, creada con Godot 4. La experiencia transcurre en *Puerto del Sur*, una ciudad ficticia junto a un lago que toma inspiración ambiental general de Nicaragua sin reproducir mapas, marcas, personajes, historias ni recursos de videojuegos existentes.

> Este repositorio contiene una primera experiencia jugable y ampliable. No es una copia de GTA 6 y no usa assets, diálogos, código ni propiedad intelectual de esa franquicia.

| Función | Implementación actual |
|---|---|
| Exploración | Personaje en tercera persona, caminar, correr, salto y cámara orbital |
| Conducción | Sedán con cuerpo rígido arcade, aceleración, frenado, giro, salida y colisiones |
| Misión | Hablar con La Chela, recoger una caja en el mercado y entregarla en el malecón |
| Controles | Teclado para pruebas y botones táctiles para Android en orientación horizontal |
| Escenario | Distrito modular con mercado, avenida, malecón, bodega, lago y faroles |
| Atmósfera | Noche lluviosa, niebla, reflejos de color, cámara suave y audio procedural |
| Recursos 3D | Cuatro GLB ligeros con licencia CC0 y manifiesto de procedencia |

## Identidad y límites creativos

La misión y los avisos usan español nicaragüense moderado y original. Se emplean expresiones locales como “maje”, “diay” y “tuani” únicamente como tono contextual, sin atribuirlas a personas reales ni imitar interpretaciones de ninguna obra. Las referencias visuales se limitan a una ciudad ficticia de clima tropical y lacustre.

## Controles

| Acción | Teclado de prueba | Pantalla táctil |
|---|---|---|
| Caminar o conducir | `W`, `A`, `S`, `D` | Cruceta inferior izquierda |
| Saltar | `Espacio` | `SALTA` |
| Usar o entrar al vehículo | `E` | `USAR` |
| Salir del vehículo | `F` | `BAJA` |
| Rotar cámara | Arrastrar con botón izquierdo | Arrastrar por el lado derecho de la pantalla |

## Abrir el proyecto

Instala Godot 4.3 o una versión compatible, abre `project.godot` y ejecuta la escena principal. El proyecto usa el renderizador de compatibilidad, geometría modular y efectos contenidos para mantener una base razonable para Android.

## Crear el APK sin Android Studio

El repositorio incluye `.github/workflows/build.yml`. Cada envío a `main` o `master`, y cualquier ejecución manual del workflow, crea un APK de depuración como artefacto llamado **ManaguaCity-Android-APK**. La configuración de exportación está en `export_presets.cfg`; el APK no está firmado para Google Play, por lo que es apropiado para pruebas locales.

```text
GitHub → pestaña Actions → Build for Android → Run workflow
```

También hay una guía práctica para el flujo desde Android y Termux en [`docs/TERMUX.md`](docs/TERMUX.md).

## Recursos y licencias

Los modelos de vehículo, caja, cono y rueda proceden de **Kenney Car Kit 3.1**, publicado con licencia **CC0**. Sus archivos originales de licencia, hashes y propósito concreto están en [`assets/models/third_party/kenney_car_kit/MANIFEST.md`](assets/models/third_party/kenney_car_kit/MANIFEST.md). El registro completo de selección de assets aparece en [`docs/ASSET_SOURCES.md`](docs/ASSET_SOURCES.md). [1]

El icono de la aplicación es una obra visual original generada para este proyecto. La geometría del distrito, scripts, misión, UI y audio procedimental son contenidos propios de este repositorio.

## Estructura

```text
escenas/                  Escena principal, personaje, vehículo y HUD
scripts/core/             Estado global, inicio y audio procedural
scripts/player/           Movimiento a pie y cámara
scripts/vehicles/         Física arcade del sedán
scripts/missions/         Máquina de estados de la misión inicial
scripts/world/            Distrito modular y clima nocturno
assets/models/            GLB con manifiesto y licencia
.github/workflows/        Compilación de APK mediante GitHub Actions
```

## Siguientes extensiones sugeridas

La arquitectura está preparada para ampliar el distrito, añadir rutas, variantes de vehículos, conversaciones, peatones, tráfico y más encargos originales. Antes de incorporar un asset de terceros, debe registrarse su licencia y fuente conforme a `docs/ASSET_SOURCES.md`.

## Referencias

[1]: https://kenney.nl/assets/car-kit "Kenney — Car Kit"
