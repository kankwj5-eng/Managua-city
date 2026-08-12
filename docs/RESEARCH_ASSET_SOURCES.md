# Investigación de fuentes de recursos

## OpenStreetMap

La página oficial de copyright de OpenStreetMap indica que los datos están bajo la Open Data Commons Open Database License (ODbL). Se pueden copiar, distribuir, transmitir y adaptar, siempre que se dé crédito a OpenStreetMap y sus colaboradores. Si los datos se modifican o se construye sobre ellos, el resultado debe distribuirse bajo la misma licencia. El juego deberá incluir una atribución visible, por ejemplo `© OpenStreetMap contributors`, junto con un enlace a https://www.openstreetmap.org/copyright o una pantalla de créditos accesible desde el menú.

Fuente consultada: https://www.openstreetmap.org/copyright

## Quaternius

El sitio oficial de Quaternius ofrece paquetes de recursos 3D gratuitos organizados por categorías como Characters, Animated, Buildings, Nature y Vehicles. Entre los paquetes visibles se encuentran Universal Base Characters, Universal Animation Library, Modular Character Outfits, Downtown City MegaKit, Stylized Nature MegaKit, Zombie Apocalypse Kit y otros paquetes de entorno y vehículos. Antes de integrar cada paquete se debe conservar el archivo de licencia o atribución correspondiente dentro de `docs/third_party/` y verificar el detalle de licencia en la página individual del paquete.

Fuente consultada: https://quaternius.com/

## Criterio de integración

Se priorizarán recursos con licencia explícita que permita uso en videojuegos y redistribución dentro del proyecto. No se incorporarán modelos descargados de páginas que no indiquen claramente sus derechos. Los mapas reales de Nicaragua se usarán como referencia o como datos transformados con atribución, no como una copia directa de material propietario.

## Paquetes concretos verificados

### Quaternius — Universal Base Characters

La página oficial del paquete indica que incluye 6 modelos de personajes, con proporciones Superhero, Regular y Teen, modelos masculinos y femeninos, topología optimizada para animación, rig humanoide y formatos FBX, OBJ y glTF. También indica un promedio de 13.000 triángulos por personaje, compatibilidad con la Universal Animation Library y licencia CC0, incluyendo uso personal, educativo y comercial. La página menciona compatibilidad con Godot 4.3 en la versión fuente.

Fuente: https://quaternius.com/packs/universalbasecharacters.html

### Kenney — Car Kit

La página oficial de Kenney identifica el Car Kit como un paquete 3D de transporte y muestra la licencia Creative Commons CC0. Se considera apto para poblar las calles con vehículos genéricos, siempre conservando la atribución y documentación del paquete dentro de los créditos del proyecto aunque CC0 no la exija.

Fuente: https://kenney.nl/assets/car-kit

## Datos geográficos de Nicaragua

### SimpleMaps — Free GIS Maps of Nicaragua

SimpleMaps ofrece archivos GIS simplificados de Nicaragua, incluido GeoJSON y Shapefile, en proyección WGS84. La página consultada indica licencia Creative Commons Attribution 4.0 y un archivo GeoJSON de aproximadamente 303,4 KB para las áreas administrativas de primer nivel. La fuente es adecuada para un mapa de selección de regiones, una minimapa estilizada o una capa de referencia de departamentos, no para generar por sí sola una ciudad 3D completa.

Fuente: https://simplemaps.com/gis/country/ni

### Geofabrik — Extracto OpenStreetMap de Nicaragua

Geofabrik publica un extracto `nicaragua-latest.osm.pbf` de aproximadamente 58 MB, utilizable con herramientas como Osmium, Osmosis, imposm, osm2pgsql y otras. La página identifica la licencia ODbL 1.0 y atribuye los datos a los colaboradores de OpenStreetMap. El archivo es una base geográfica de carreteras, lugares y elementos cartográficos, pero requiere un proceso adicional de conversión para transformarlo en geometría jugable de Godot; no se debe copiar directamente al proyecto sin preparar y simplificar los datos.

Fuente: https://download.geofabrik.de/central-america/nicaragua.html

## Decisión

No se encontró un mod gratuito claramente autorizado que sea una recreación completa de Managua lista para importar a Godot. Se utilizará el modelo GLB de la ciudad que ya proporcionó el usuario como escenario principal, y los datos abiertos de Nicaragua se emplearán de forma selectiva para nombres, regiones, carreteras de referencia y composición del mundo. Los recursos de personajes de Quaternius y vehículos de Kenney son las primeras fuentes externas aptas para descargar e integrar.

## Verificación de descarga de personajes

La página oficial de Universal Base Characters fue inspeccionada y su contenido HTML quedó guardado para localizar el enlace de descarga oficial. La ficha confirma glTF entre los formatos visibles y CC0 como licencia. Se usará únicamente el enlace de descarga que figure en esa página, evitando mirrors o archivos de procedencia desconocida.

## Descarga pública

La ficha oficial de itch.io de Quaternius presenta Universal Base Characters como un paquete de assets descargable bajo modalidad name-your-price. La página oficial enlazada desde la ficha de Quaternius es `https://quaternius.itch.io/universal-base-characters`. La integración debe conservar la licencia CC0 indicada por Quaternius y descargar únicamente desde esa fuente oficial.

## Contenido gratuito disponible del paquete NPC

La página pública de itch.io especifica que el paquete Standard de Universal Base Characters pesa 122 MB y que incluye una parte gratuita con 2 modelos base y 5 peinados. La página también indica que esos modelos pueden usarse en proyectos personales, educativos y comerciales bajo CC0. La versión Source de 600 MB requiere una contribución económica y no es necesaria para comenzar; por tanto, el objetivo será integrar primero el contenido Standard gratuito.

Fuente: https://quaternius.itch.io/universal-base-characters

## Acceso a la descarga

La descarga gratuita fue abierta desde la ficha oficial. La página de descarga muestra `Universal Base Characters[Standard].zip` con tamaño de 122 MB y ofrece un botón de descarga directo. También indica que los modelos glTF son adecuados para importar en motores de juego. El archivo todavía debe descargarse y descomprimirse antes de seleccionar los modelos NPC que se incorporarán al proyecto.

## Descarga completada

El archivo oficial `Universal Base Characters[Standard].zip` se descargó en `/home/ubuntu/Downloads/` con un tamaño de 128,968,391 bytes. Se verificará su contenido antes de copiar cualquier recurso al repositorio; no se ejecutará ningún archivo incluido en el ZIP.
