# Managua City

Proyecto base en **Godot 4.7.2** para un juego 3D móvil ambientado en la ciudad del mapa recibido.

## Recursos integrados

La ciudad original `untitled.3ds` fue convertida a `assets/city/managua_city.glb`. Sus 376 texturas PNG fueron copiadas junto al modelo para que Godot pueda resolver las referencias de materiales. El NPC recibido fue incorporado como `assets/npc/npc.glb`.

La escena inicial es `scenes/main.tscn`. Incluye la ciudad, el NPC, una cámara 3D, cielo procedural y una luz direccional con sombras limitadas.

## Línea base móvil

El proyecto usa el **Mobile Renderer** de Godot 4. La configuración futura seguirá estas decisiones: resolución interna baja con stretch, escalado dinámico según FPS, iluminación horneada como opción principal, sombras dinámicas simples y limitadas, LOD, occlusion culling, texturas ETC2/ASTC en exportación Android y batching/instancing para elementos repetidos.

FSR 1 se añadirá en el siguiente pase de render cuando definamos el perfil de resolución interna y el método final de escalado de pantalla. El denoising por IA queda fuera de la línea base por su costo en dispositivos de gama baja.

## Nota de importación

El archivo 3DS referencia algunos nombres de textura que no existen en el paquete original; Godot reporta esas referencias ausentes durante la importación, pero el modelo y el NPC se importan correctamente. Esas superficies deberán recibir materiales de reemplazo o texturas corregidas durante la fase de arte y optimización.

## Ejecución

```bash
/home/ubuntu/.local/bin/godot --editor --path /home/ubuntu/managua-city
```

## Controles

En PC se puede mover el personaje principal con **WASD** o las flechas. En Android se muestran cuatro botones táctiles en la esquina inferior izquierda. El primer NPC es el personaje controlable en esta versión; los otros modelos permanecen como NPCs de la ciudad.

## Exportación Android

Para crear la APK en un equipo con Godot, instala las plantillas de exportación Android y configura el Android SDK/JDK desde `Editor > Editor Settings > Export > Android`. Luego crea un preset Android y ejecuta `Project > Export Project > Android`. La escena ya está preparada para recibir ese preset.

## Pase de producción visual

Los tres modelos NPC miden aproximadamente un metro en sus archivos originales. Se normalizaron a una escala de **1.75 metros**, aplicada al personaje principal, NPCs iniciales y copias de los barrios, para que su proporción sea más natural frente a la ciudad.

Se retiró el hospital por indicación del diseño. Se conservaron acentos de vegetación ligeros, con geometría económica y materiales verdes/marrones, pensados para reemplazarse posteriormente por un atlas de vegetación de mayor calidad.

## Animación y esqueletos

Los tres GLB recibidos contienen una sola malla, cero huesos y cero animaciones. El proyecto conserva el controlador procedural de reposo, caminar, correr y pelea, pero los movimientos reales de brazos y piernas requieren una versión riggeada de cada personaje. Cuando se disponga de esos archivos se podrá usar `SkeletonProfileHumanoid`, `AnimationTree` y retargeting de Godot.

## IA en el juego

`DialogueAI` define la interfaz de diálogo y mantiene respuestas locales para que la APK funcione sin conexión. Puede conectarse a un backend seguro mediante `endpoint`; no se guardan claves de API dentro del juego. El denoiser adaptativo y el escalado de resolución son los pases de reconstrucción visual apropiados para móvil; una red neuronal cuadro por cuadro pesada no se activa porque dañaría el rendimiento de gama baja.

## Cámara y escala humana

Los NPCs y el personaje se normalizan a **1.80 m**. La cámara orbital sigue al personaje, permite girar horizontalmente 360° sin límite y mirar arriba/abajo entre -55° y +35°. En PC se controla arrastrando con el botón izquierdo del mouse; en Android se utiliza el gesto de arrastre sobre la pantalla.
