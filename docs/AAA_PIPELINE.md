# Blueprint Técnico y Hoja de Ruta AAA — Ciudad del Lago / Managua City

## 1. Arquitectura de Sistemas Independientes

Para lograr el estándar técnico AAA en dispositivos móviles (Android) utilizando herramientas de código abierto y Godot 4, el proyecto se divide en 8 sistemas principales independientes:

```text
[ Terreno y Geografía Real ] ---> ( Heightmaps SRTM / QGIS / Blender )
[ Generación Urbana ]        ---> ( OpenStreetMap / Geometry Nodes / CityGML )
[ Props & Vegetación ]       ---> ( MultiMeshInstancing / LOD System )
[ Materiales PBR ]           ---> ( Material Maker / PBR Textures / Shaders )
[ Vehículos & Físicas ]      ---> ( Raycast Suspension / Arcade Physics )
[ Personajes & IA ]          ---> ( Character Controller / NavigationMesh / Traffic AI )
[ Audio Director ]           ---> ( Positional 3D Audio / Dynamic Ambient Buses )
[ Optimización & Streaming ] ---> ( World Chunking / Occlusion & Frustum Culling )
```

---

## 2. Hoja de Ruta de Producción Etapa por Etapa

### Etapa 1: Preproducción y Planificación
- Análisis de requisitos y especificaciones móviles.
- Evaluación de arquitectura Godot 4.3 y verificación del flujo CI APK.
- Documentación del conjunto de herramientas FOSS (`docs/FREE_TOOLS_PIPELINE.md`).

### Etapa 2: Terreno y Geografía Real
- Malla topográfica no plana con elevaciones, colinas, pendientes, montañas, valles y depresión lacustre.
- Transiciones suaves de elevación entre el nivel del lago y las áreas altas (Loma de Tiscapa / Sierras).

### Etapa 3: Generación de Ciudades y Red Viaria
- Estructura modular de manzanas, calles, avenidas principales e intersecciones.
- Aceras, fachadas de edificios con variación de alturas, ventanas, techos, puertas y señalización vial.
- Mobiliario urbano (postes de luz, muros, contenedores, vegetación urbana).

### Etapa 4: Modelado 3D de Props y Vehículos
- Modelado en Blender de edificios de referencia y utilería.
- Integración del sedán arcade con física de suspensión, ruedas móviles y faros funcionales.
- Generación de mallas simplificadas para colisiones (`-col`) y niveles de detalle (LOD).

### Etapa 5: Texturas y Materiales PBR
- Generación de mapas PBR (Albedo, Normal, Roughness, Metallic, AO) con Material Maker / Blender.
- Materiales para asfalto, concreto, adoquines, tejas, metal, madera y cristal.

### Etapa 6: Vegetación e Instanciación Eficiente
- Modelado de árboles, arbustos, palmeras tropicales y hierba.
- Posicionamiento procedural e instanciación con `MultiMeshInstance3D` para minimizar Draw Calls.

### Etapa 7: Vehículos y Controladores
- Sistema de físicas de vehículo arcade en Godot 4.
- Interacción de entrada/salida de vehículo para el jugador.
- Efectos visuales y de audio (derrape, motor, colisiones).

### Etapa 8: Personajes, Animación y Tráfico NPC
- Locomoción en tercera persona (caminar, correr, saltar) y cámara orbital SpringArm3D.
- Tráfico simple de ciudadanos y patrullas policiales en rutas.

### Etapa 9: Gameplay, UI y Misiones
- HUD táctil para Android con minimapa, velocímetro y barra de salud.
- Control del ciclo de misión (recolección y entrega de paquetes).
- Guardado y persistencia del estado de juego (`GameState.gd`).

### Etapa 10: Iluminación, Atmósfera y Realismo
- Sistema de luz solar direccional (`DirectionalLight3D`) con cielo físico (`PhysicalSkyMaterial`).
- Niebla volumétrica ligera y mapas de reflejo (`ReflectionProbe`).

### Etapa 11: Audio Multicapa
- Buses de audio independientes para música, efectos, motor y voz.
- Sonidos posicionables 3D (`AudioStreamPlayer3D`) para la costa, el mercado y el ambiente urbano.

### Etapa 12: Optimización AAA y Streaming
- Visibilidad por frustum (`VisibleOnScreenNotifier3D`).
- Reutilización de materiales y texturas comprimidas ETC2/ASTC para Android.

### Etapa 13: Fase Alpha
- Verificación completa del ciclo jugable sin errores de script ni caídas de fotogramas masivas.

### Etapa 14: Fase Beta
- Ajustes de fricción, refinamiento de iluminación y pulido de materiales PBR.

### Etapa 15: Pulido Final
- Ajuste fino de la escena principal `escenas/Main.tscn`, incorporación de pequeños detalles en el mapa y verificación pre-commit.
