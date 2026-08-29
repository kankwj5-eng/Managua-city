# Herramientas Gratuitas y Libres (FOSS) para el Flujo AAA del Proyecto

Este documento detalla la investigación de herramientas gratuitas, de código abierto y sin coste comercial seleccionadas para la producción del proyecto 3D.

---

## 1. Terreno y Geografía Real (DEM / GIS)

### **QGIS**
- **Descripción:** Sistema de Información Geográfica (GIS) de código abierto (GPLv2).
- **Disponibilidad en Linux/Ubuntu:** Sí (`sudo apt install qgis`).
- **Función en el flujo:** Importar datos de elevación SRTM (NASA 30m) o DEM de alta resolución, recortar el área de estudio (Managua / Tiscapa / Estelí / Valle del Lago), exportar mapas de altura GeoTIFF o RAW de 16-bit.
- **Integración:** El mapa de altura (Heightmap 16-bit) se importa directamente a Blender o Godot (HeightMap Terrain plugin).

### **SRTM / OpenTopography / USGS EarthExplorer**
- **Descripción:** Fuentes abiertas de datos de elevación digital del terreno (DEM).
- **Función:** Proporcionar elevaciones reales para montañas, valles, colinas y pendientes topográficas.

---

## 2. Generación Procedural de Ciudades

### **Blender (Geometry Nodes & OSM Import)**
- **Descripción:** Suite 3D libre (GPL) con potentes nodos de geometría procedural.
- **Alternativa FOSS a CityEngine / Houdini:** geometry nodes permite extruir manzanas urbanas, generar calles con aceras, distribuir edificios procedurales con fachadas, ventanas, techos, puertas, cables y vegetación urbana según curvas de nivel o redes viarias.
- **Complementos FOSS:** *Blender-OSM* (importa trazados de calles y edificios reales de OpenStreetMap a Blender sin coste).
- **Formatos de exportación:** GLTF / GLB 2.0 (con soporte de materiales PBR, LODs y colisiones `-col`).

---

## 3. Modelado 3D, Props y Vehículos

### **Blender 4.x**
- **Descripción:** Estándar de la industria en software libre para modelado 3D, rigging, skinning y animación.
- **Disponibilidad:** Linux/Ubuntu, Windows, macOS.
- **Función:**
  - Modelado de edificios, vehículos, señalización, vegetación y mobiliario urbano.
  - Creación de LODs (Level of Detail: LOD0, LOD1, LOD2).
  - Rigging de personajes y física de suspensión de vehículos.

---

## 4. Texturas y Materiales PBR

### **Material Maker**
- **Descripción:** Generador procedimental de texturas PBR basado en nodos, de código abierto (MIT), hecho sobre el motor Godot.
- **Disponibilidad:** AppImage nativo para Linux/Ubuntu y ejecutable ejecutable.
- **Función:** Generación de mapas PBR (Albedo/Base Color, Normal, Roughness, Metallic, Ambient Occlusion) para asfalto, concreto, tejas, ladrillos, madera, metal y cristal.
- **Integración:** Exportación directa de mapas PBR a GLTF o materiales `.tres` / `.material` para Godot.

### **ArmorPaint**
- **Descripción:** Herramienta de pintura 3D PBR de código abierto.
- **Función:** Texturizado y pintura directa sobre mallas 3D para vehiculos, accesorios y accesorios urbanos.

---

## 5. Personajes, Animación y Locomoción

### **Mixamo (Versión gratuita de Adobe) / Carnegie Mellon Motion Capture Database (Free)**
- **Descripción:** Colección de animaciones de captura de movimiento (MoCap) y autorigging sin coste comercial para proyectos independientes.
- **Blender Rigify:** Sistema interno de rigging en Blender para personajes con controles IK/FK.

---

## 6. Integración de Motor, Físicas y Optimización

### **Godot Engine 4.3 (Compatibilidad Android / Mobile)**
- **Descripción:** Motor de videojuegos libre (MIT).
- **Rol:** Integración de sistemas de juego, motor de física 3D, renderizado PBR (Mobile Compatibility GL ES 3.0 / Vulkan), iluminación natural/artificial, audio posicionable y exportación automatizada APK.
- **Optimización AAA:**
  - *GridMap & MultiMeshInstance3D:* Instanciación masiva de vegetación, postes y edificios sin penalización de Draw Calls.
  - *Frustum Culling & Visibility Notifiers:* Desactivación de mallas fuera de cámara.
  - *World Streaming / Chunking:* Carga dinámica de cuadrículas del terreno.

---

## 7. Edición y Procesamiento de Audio

### **Audacity / Tenacity**
- **Descripción:** Editor de audio multipista de código abierto (GPL).
- **Función:** Edición, normalización y exportación de efectos de sonido (WAV 16-bit / OGG) para vehículos, pasos, ambiente de lluvia/viento y ciudad.
