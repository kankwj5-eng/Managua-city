# Auditoría de `awesome-citygml`

## Resultado

El repositorio [`OloOcki/awesome-citygml`](https://github.com/OloOcki/awesome-citygml) es un catálogo curado de fuentes abiertas de modelos semánticos 3D urbanos; no es un paquete de modelos de Managua listo para copiar al proyecto. Su README enumera países, ciudades, niveles de detalle y enlaces externos de descarga. En la lista visible de países no aparece Nicaragua ni Managua. Por tanto, clonar el repositorio no añade por sí solo edificios 3D de Nicaragua al juego.

El repositorio del catálogo tiene licencia MIT, pero esa licencia sólo cubre el código y la documentación del catálogo. Cada dataset externo enlazado conserva sus propias condiciones de uso. No se deben copiar modelos de Berlín, Tokio, Luxemburgo u otras ciudades para presentarlos como Managua, ni asumir que la licencia MIT del catálogo cubre esos datos.

## Decisión para Ciudad del Lago

No se incorporan al juego datasets externos de ciudades que no sean Nicaragua. Se conserva una copia local del catálogo fuera del proyecto como material de investigación y se documenta esta revisión. Para Managua se continuará usando geometría procedural propia basada en referencias abiertas, con zonas de barrio, mercado, avenida, Tiscapa, Puerto Salvador Allende, playa y lago Xolotlán.

Los recursos que sí pueden aprovecharse del catálogo son sus referencias metodológicas y la identificación de herramientas para inspeccionar o convertir CityGML. Si en el futuro aparece un dataset oficial de Nicaragua con licencia compatible, se puede crear un importador o convertir una selección limitada de edificios a glTF/GLB para Android, manteniendo su atribución y condiciones originales.

## Fuentes consultadas

1. Catálogo y README de `awesome-citygml`: <https://github.com/OloOcki/awesome-citygml>.
2. Licencia del catálogo: <https://github.com/OloOcki/awesome-citygml/blob/main/LICENSE>.
3. Estándar CityGML de OGC: <https://www.ogc.org/standards/citygml/>.
4. Extracto abierto de Nicaragua de OpenStreetMap en Geofabrik: <https://download.geofabrik.de/central-america/nicaragua.html>.
5. OpenStreetMap — atribución y licencia ODbL: <https://www.openstreetmap.org/copyright>.

## Candidatos revisados en el catálogo

El catálogo enlaza, entre otros, estas fuentes externas que podrían aportar geometría urbana, carreteras, árboles o infraestructura:

| Fuente | Formatos o contenido indicado por el catálogo | Enlace oficial |
|---|---|---|
| Japón / PLATEAU | Edificios LoD1/LoD2, carreteras, áreas de planificación y varias ciudades | <https://www.geospatial.jp/ckan/dataset/plateau> |
| Riga | CityGML, SketchUp, OBJ, 3DS, GDB, árboles y mallas | <https://georiga.eu/en/atvertie-dati/lod2/> |
| Luxemburgo | Edificios LoD2, puentes, ferrocarril, árboles, nubes de puntos, DSM/DTM y ortofotos | <https://data.public.lu/en/datasets/base-de-donnees-nationale-des-batiments-3d-2023/> |
| Luxemburgo — muestras | Muestras LoD2 y LoD1 para descarga independiente | <https://data.public.lu/en/datasets/5cf4e1230f7fb0030af0771a/> |
| Berlín | Edificios LoD1/LoD2 y una malla urbana | Fuente enlazada en el README del catálogo; requiere revisar licencia específica antes de redistribuir |
| Melbourne/Victoria | Modelos urbanos y datos de elevación | Fuente enlazada en el README del catálogo; requiere revisar licencia específica antes de redistribuir |

Estos enlaces son catálogos o portales oficiales; el permiso de redistribución del dataset concreto no se deduce de la licencia MIT del repositorio `awesome-citygml`. Sólo se copiarán al juego archivos pequeños con licencia y atribución verificadas.

## Verificación de portales oficiales

La página oficial de PLATEAU afirma que sus modelos pueden utilizarse gratuitamente incluso con fines comerciales, pero el registro CKAN visible muestra `Licencia: no especificada`; por prudencia no se empaquetarán sus datos hasta resolver esa discrepancia con los términos oficiales del proyecto.

El portal de Riga indica que sus modelos LoD2 están disponibles en GML/CityGML, OBJ, 3DS y otros formatos, bajo condiciones de reutilización enlazadas a CC BY 4.0. Es una fuente técnicamente aprovechable, pero no se copiará a la APK hasta conservar la atribución y confirmar el alcance de la licencia para los archivos elegidos.

El portal oficial de Luxemburgo publica muestras de edificios 3D LoD 2.3 en CityGML con licencia CC0, y también un dataset nacional 2023 LoD 2.2 con edificios y texturas en archivos comprimidos por municipio, igualmente con licencia CC0. La muestra pequeña es la candidata más segura para probar la conversión a un formato ligero; el dataset nacional completo es demasiado grande para incluirlo indiscriminadamente en una APK Android.

Fuentes: [PLATEAU](https://www.geospatial.jp/ckan/dataset/plateau), [Riga LoD2](https://georiga.eu/en/atvertie-dati/lod2/), [Luxemburgo LoD2.3](https://data.public.lu/en/datasets/5cf4e1230f7fb0030af0771a/), [Luxemburgo BD-L-BATI3D](https://data.public.lu/en/datasets/base-de-donnees-nationale-des-batiments-3d-2023/).

## Confirmación adicional de Luxemburgo

La ficha oficial de la muestra de Luxemburgo confirma que cubre sólo 3 km² de Diekirch y Bastendorf, que el formato es CityGML y que la licencia es CC0. La ficha también señala que la documentación de archivos está incompleta; por ello, antes de incorporarla habría que localizar el archivo exacto y verificar su estructura. Esta muestra no es un modelo de Managua, pero puede servir como escenario urbano de referencia si se convierte y se etiqueta claramente como ciudad invitada.

## Recurso descargable localizado

La API oficial de data.public.lu expone un único archivo para la muestra CC0: `LOD2_batiments_diekirch_bastendorf.gml`, formato GML/CityGML, tamaño aproximado de 57.9 MB, SHA-1 `d416997beb8a44d51cf824d1e4ddabe7266ec2ee`.

URL directa: <https://download.data.public.lu/resources/batiments-3d-lod-2-3-level-of-detail-2-3/20190603-110058/lod2-batiments-diekirch-bastendorf.gml>.

La fuente oficial de metadatos es <https://data.public.lu/api/1/datasets/5cf4e1230f7fb0030af0771a/>. El archivo es una muestra urbana de Luxemburgo, no Managua; si se integra, debe rotularse como escenario invitado y no como ciudad nicaragüense.
