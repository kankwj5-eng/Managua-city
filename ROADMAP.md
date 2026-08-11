# Managua City - plan paso a paso

Este roadmap divide el proyecto en etapas pequeñas para avanzar hacia un mundo abierto tipo urbano sin romper la base jugable.

## Etapa 1 - Base estable, ambiente y sonido inicial

Estado: implementada en este commit.

Objetivos:

- Estabilizar el flujo de misión para que el marcador final no quede referenciado después de ser eliminado.
- Añadir un `AudioManager` global con sonidos generados de prueba para disparo, recarga, arma vacía, pickup, misión y alerta Redane.
- Añadir una primera pasada de atmósfera visual con cielo procedural, luz ambiental, glow y niebla suave.
- Subir la intensidad/calidad básica de la luz solar de la escena principal.

Criterio de terminado:

- La escena sigue cargando `managua_ciudad.glb` y `personaje_relieve.glb`.
- El HUD sigue recibiendo misiones.
- Disparos y pickups tienen feedback sonoro temporal.
- El ambiente ya no depende solo de una luz direccional plana.

## Etapa 2 - Controles formales y loop de combate

Estado: primera implementación integrada.

Objetivos:

- Mover acciones (`shoot`, `interact`, `sprint`, `reload`) a `project.godot`. ✅
- Añadir recarga manual. ✅
- Añadir cooldown de disparo. ✅
- Añadir feedback visual de impacto. ✅
- Eliminar teclas debug de salud o esconderlas tras modo debug. ✅

## Etapa 3 - Enemigos con navegación real

Estado: primera implementación integrada.

Objetivos:

- Crear `NavigationRegion3D` para zonas caminables.
- Migrar patrullas a `NavigationAgent3D`. ✅
- Agregar estados: patrullar, investigar ruido, perseguir, atacar, perder al jugador. ✅
- Hacer que el nivel Redane suba y baje según persecución/escape. ✅

## Etapa 4 - Ciudad viva

Estado: primera implementación integrada.

Objetivos:

- Agregar props urbanos reutilizables: postes, barreras y carteles. ✅
- Añadir NPCs civiles simples. ✅
- Añadir eventos aleatorios: patrulla, rescate, emboscada, pickup raro.
- Añadir marcadores de misión visibles en minimapa.

## Etapa 5 - Gráficos de ciudad

Estado: primera implementación integrada.

Objetivos:

- Revisar materiales importados del GLB.
- Crear materiales PBR base para nuevos props urbanos. ✅
- Añadir decals de grietas, suciedad, grafitis y señales de Redane.
- Añadir iluminación urbana puntual en faroles. ✅
- Optimizar sombras, LOD y colisiones para Android.

## Etapa 6 - Audio real

Estado: primera implementación técnica integrada; faltan archivos finales.

Objetivos:

- Reemplazar tonos placeholder por archivos `.ogg` o `.wav`.
- Añadir buses `Music`, `SFX`, `UI` y `Ambient`. ✅
- Añadir ambiente urbano en loop.
- Añadir pasos por superficie.
- Añadir voces/alertas de Redane.
- Añadir música dinámica de exploración y persecución.

## Etapa 7 - Misiones narrativas completas

Objetivos:

- Convertir las tres pistas iniciales en misiones con objetivos jugables.
- Añadir diálogos, subtítulos y cinemáticas simples.
- Añadir sistema de inventario de evidencias.
- Añadir guardado/carga de progreso.
