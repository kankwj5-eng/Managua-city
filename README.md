# Ciudad del Lago

**Ciudad del Lago** es una vertical slice original de acción y conducción en tercera persona para Android, creada con Godot 4. La primera ruta jugable está ambientada en zonas ficticias inspiradas en Managua, el Mercado Oriental, el Barrio Altagracia, la Loma de Tiscapa, el Puerto Salvador Allende y la costa del lago Xolotlán. No reproduce un mapa comercial ni utiliza recursos de una franquicia existente.

> Este repositorio contiene una primera experiencia jugable y ampliable. No es una copia de GTA 6 y no usa assets, diálogos, código ni propiedad intelectual de esa franquicia.

| Función | Implementación actual |
|---|---|
| Exploración | Personaje en tercera persona, caminar, correr, salto y cámara orbital |
| Conducción | Sedán con cuerpo rígido arcade, aceleración, frenado, giro, salida y colisiones |
| Misión | Hablar con La Chela, recoger una caja en el mercado y entregarla en el malecón |
| Controles | Teclado para pruebas y botones táctiles para Android en orientación horizontal |
| Escenario | Distrito modular con mercado, avenida, malecón, bodega, lago y faroles |
| Atmósfera | Día tropical, cielo abierto, luz solar, vegetación, costa, mercado y audio ambiental |
| Acción | Pistola de prueba, destello, nivel de alerta y patrullas policiales |
| NPCs | Ciudadanos y policías low-poly con nombres, oficios y diálogos interactivos |
| Recursos 3D | Geometría procedural ligera, distrito CityGML convertido, vehículo Kenney CC0 y sonidos originales WAV |

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

El vehículo procede de **Kenney Car Kit 3.1**, publicado con licencia **CC0**. Sus archivos originales de licencia, hashes y propósito concreto están en [`assets/models/third_party/kenney_car_kit/MANIFEST.md`](assets/models/third_party/kenney_car_kit/MANIFEST.md). La geometría de Lenner, los ciudadanos, las patrullas, los edificios, la vegetación y las zonas del mapa son recursos procedurales propios del proyecto. El registro completo de fuentes aparece en [`docs/ASSET_SOURCES.md`](docs/ASSET_SOURCES.md). [1]

El icono de la aplicación es una obra visual original generada para este proyecto. La geometría del distrito, scripts, misión, UI y los efectos de audio WAV de la vertical son contenidos propios de este repositorio. La guía geográfica y cultural usada para diseñar las zonas está en [`docs/MANAGUA_REFERENCE.md`](docs/MANAGUA_REFERENCE.md).

Como escenario urbano adicional se incluye `assets/models/citygml/diekirch_bastendorf_reference.glb`, una conversión ligera del archivo CityGML oficial de Diekirch/Bastendorf, Luxemburgo. La fuente declara licencia **CC0**; el archivo convertido se usa como distrito urbano invitado y no se presenta como un mapa real de Managua. La descarga, checksum, formato y fuente están documentados en [`docs/CITYGML_CATALOG_REVIEW.md`](docs/CITYGML_CATALOG_REVIEW.md).

## Estructura

```text
escenas/                  Escena principal, personaje, vehículo y HUD
scripts/core/             Estado global, inicio y audio ambiental
scripts/player/           Movimiento a pie, acción y cámara
scripts/vehicles/         Física arcade del sedán
scripts/missions/         Máquina de estados de la misión inicial
scripts/world/            Distrito diurno, ciudadanos y policía
assets/audio/             Ambiente, olas y efectos de jugabilidad
assets/models/            Vehículo, distrito CityGML y recursos con manifiestos de licencia
.github/workflows/        Compilación de APK mediante GitHub Actions
```

## Contenido de la vertical actual

La primera misión se llama «La última llamada». Lenner inicia en la zona barrial y debe encontrar a La Chela en el Mercado Oriental, recoger un paquete y entregarlo en el muelle del Puerto Salvador Allende. En el trayecto puede correr, saltar, interactuar, usar un vehículo y disparar en modo de prueba; un disparo activa la alerta policial y las patrullas se acercan. El HUD muestra el objetivo, la recompensa, los diálogos, el estado a pie o en vehículo y el nivel de alerta.

Los diálogos usan jerga nicaragüense moderada y contextual: «diay», «maje», «tuani», «pues», «no te metás en clavos» y «dale suave». El objetivo es que el tono se sienta local sin convertir a los personajes en una caricatura.

## Siguientes extensiones sugeridas

La arquitectura está preparada para ampliar el distrito, añadir rutas, variantes de vehículos, conversaciones, peatones, tráfico y más encargos originales. Antes de incorporar un asset de terceros, debe registrarse su licencia y fuente conforme a `docs/ASSET_SOURCES.md`.

## Referencias

[1]: https://kenney.nl/assets/car-kit "Kenney — Car Kit"
