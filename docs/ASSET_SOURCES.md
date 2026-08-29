# Registro de procedencia de assets

## Política del proyecto

El proyecto acepta únicamente recursos originales, de dominio público o con licencias explícitas compatibles con distribución en el repositorio y con un APK de prueba. No se incorporan modelos, audio ni texturas extraídos de videojuegos comerciales o franquicias ajenas. Cada recurso externo conserva su fuente, licencia y propósito.

## Recursos actualmente incorporados

| Recurso | Uso | Procedencia y licencia | Estado |
|---|---|---|---|
| Geometría procedural de Managua | Calles, barrios, Mercado Oriental, Loma de Tiscapa, Puerto Salvador Allende, playa y lago Xolotlán | Código original de este proyecto | Incorporado |
| Lenner procedural | Personaje principal, camisa azul y blanca, pantalón y pistola de prueba | Geometría original creada dentro de Godot para esta vertical | Incorporado |
| Ciudadanos y policías low-poly | Población interactiva, patrullas y diálogos | Geometría original creada dentro de Godot para esta vertical | Incorporado |
| Kenney Car Kit | Sedán y piezas del vehículo de prueba | Creative Commons CC0, fuente oficial [1] | Incorporado |
| Sonidos WAV de la vertical | Ambiente diurno, mercado, olas, salto, acción, diálogo y sirena | Síntesis original generada para este proyecto | Incorporado |

## Referencias geográficas y culturales

Las zonas jugables no son una copia exacta de un mapa comercial. Se diseñaron usando nombres y rasgos generales de fuentes abiertas y turísticas sobre Managua, el lago Xolotlán y sus puntos de interés. El resumen de referencias se encuentra en [`docs/MANAGUA_REFERENCE.md`](MANAGUA_REFERENCE.md).

Para futuras ampliaciones cartográficas, las fuentes de datos abiertas consideradas son OpenStreetMap, que exige atribución y cumplimiento de la licencia ODbL [2], y las descargas de Nicaragua de Geofabrik, que distribuyen extractos de OpenStreetMap [3]. En esta versión no se empaqueta un extracto OSM dentro del juego: la escena usa geometría procedural ligera para mantener una APK Android pequeña y evitar problemas de importación.

## Recursos eliminados

Se retiraron del proyecto el relieve GLB que producía una presentación oscura o incompleta, el modelo proporcionado de Lenner que se veía borroso en el dispositivo y los modelos de superhéroe usados como NPC. La población y el personaje actuales ya no dependen de esos archivos.

## Reglas para futuras incorporaciones

1. Descargar únicamente desde la página oficial del autor o proveedor.
2. Conservar la licencia y el enlace de origen junto al recurso.
3. Inspeccionar el paquete sin ejecutar binarios o scripts de terceros.
4. Elegir modelos ligeros y reducir materiales, texturas y animaciones para Android.
5. Registrar el recurso en este documento antes de hacer push.

## Referencias

[1]: https://kenney.nl/assets/car-kit "Kenney — Car Kit"
[2]: https://www.openstreetmap.org/copyright "OpenStreetMap — Copyright and License"
[3]: https://download.geofabrik.de/central-america/nicaragua.html "Geofabrik — Nicaragua OSM extract"
