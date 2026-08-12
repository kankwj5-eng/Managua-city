# Registro de procedencia de assets

## Política del proyecto

El proyecto acepta únicamente recursos **originales**, de dominio público o con licencias explícitas compatibles con distribución en el repositorio y con un APK. Todo GLB incorporado debe conservar su URL de origen, licencia, versión, autor o proveedor y fecha de descarga. No se incorporan modelos, audio ni texturas extraídos de videojuegos comerciales o franquicias ajenas.

| Recurso candidato | Uso previsto | Formato a verificar | Licencia confirmada | Estado |
|---|---|---|---|---|
| Kenney Car Kit | Carro de referencia y piezas visuales para el sedán de prueba | GLB/GLTF dentro del paquete | Creative Commons CC0 | Aprobado como fuente; pendiente de descargar y seleccionar el archivo más ligero |
| Kenney assets 3D | Elementos urbanos y utilería secundaria | GLB/GLTF dentro del paquete | Se verificará por pack individual | En evaluación |
| Geometría procedural propia | Calles, malecón, edificios, faroles, señalización y cajas | Escenas Godot | Código original del proyecto | Aprobado |

## Fuente verificada

La página oficial de **Kenney Car Kit** indica que se trata de un pack 3D de 45 archivos bajo licencia **Creative Commons CC0**. La licencia CC0 permite reutilizar los archivos sin atribución obligatoria; aun así, el proyecto registra la fuente como práctica de trazabilidad. [1]

## Proceso de incorporación

1. Descargar el archivo oficial desde el proveedor y conservar su licencia incluida.
2. Inspeccionar sus contenidos sin ejecutar ningún binario ni script del paquete.
3. Elegir un único vehículo de bajo peso y, si procede, convertir de GLTF a GLB manteniendo crédito y licencia.
4. Colocarlo bajo `assets/models/third_party/kenney_car_kit/` con un archivo `LICENSE.txt` y un manifiesto de procedencia.
5. Verificar su importación en Godot y eliminar materiales o texturas no necesarios para Android.

## Referencias

[1]: https://kenney.nl/assets/car-kit "Kenney — Car Kit"

## Descarga iniciada

La descarga se solicitó desde el enlace oficial que el proveedor muestra tras seleccionar “Continue without donating”. Antes de integrar archivos se comprobará el contenido real del ZIP, su licencia incluida y la presencia de GLB/GLTF que pueda importarse en Godot.

| Paquete | Enlace de descarga oficial | Fecha de solicitud | Próximo control |
|---|---|---|---|
| Kenney Car Kit | `https://kenney.nl/media/pages/assets/car-kit/1a312ec241-1775131960/kenney_car-kit.zip` | 12 de agosto de 2026 | Revisar ZIP, seleccionar vehículo y conservar licencia |

Estado observado: la descarga de `kenney_car-kit.zip` se inició desde la fuente oficial y estaba en curso al verificarse. No se inspeccionará ni integrará el contenido hasta que el archivo esté completo.

## Modelos integrados

Se incorporaron cuatro GLB ligeros del paquete verificado: `sedan.glb`, `box.glb`, `cone.glb` y `wheel-dark.glb`. Cada archivo conserva el manifiesto de uso, licencia y hash SHA-256 en `assets/models/third_party/kenney_car_kit/MANIFEST.md`.

El intento de obtener una biblioteca adicional de sonidos desde un repositorio externo no pudo completarse por una incidencia temporal de resolución de red. Para no incorporar archivos cuya procedencia no se haya revisado, la vertical slice utilizará inicialmente **sintetizadores de audio propios** para motor, ambiente y confirmaciones de interfaz. La estructura deja preparada la carpeta `assets/audio/` para futuras sustituciones por sonidos con licencia explícita.
