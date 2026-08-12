# Plan de producción — Ciudad del Lago

## Propósito

**Ciudad del Lago** es una vertical slice original de acción y conducción en tercera persona para Android. Su ciudad ficticia, *Puerto del Sur*, toma referencias generales de los climas, el lago y la vitalidad urbana nicaragüenses sin representar calles, marcas, personas ni misiones de ninguna obra protegida. El proyecto no utiliza el nombre, los personajes, los mapas, los diálogos, los sonidos, los modelos ni el código de GTA 6.

> La primera entrega prioriza una experiencia completa de cinco a diez minutos sobre la extensión del mapa: explorar a pie, solicitar un vehículo, conducir, seguir una ruta, entregar un encargo y cerrar una misión.

| Elemento | Alcance de la vertical slice | Criterio de aceptación |
|---|---|---|
| Mapa | Distrito compacto modular con malecón, barrio, mercado y carretera periférica | Se recorre sin caídas, con colisiones y referencias visibles |
| Personaje | Tercera persona, caminar, correr, salto, cámara libre y entrar/salir de vehículo | Controles de teclado y pantalla responden sin conflictos |
| Vehículo | Sedán original con aceleración, dirección, frenado, derrape suave y colisiones | Es controlable a 30 FPS objetivo en un dispositivo Android medio |
| Misión | Recoger una caja en el mercado, llevarla al malecón y recibir recompensa | El HUD informa la fase y finaliza sin intervención externa |
| Atmósfera | Noche lluviosa, contraste alto, neblina, luces cálidas y paleta oscura | La iluminación transmite un tono cinematográfico sin oscurecer la jugabilidad |
| Localización | Español nicaragüense moderado, subtítulos y avisos propios | Sin imitar diálogos ni identidades de franquicias existentes |
| Android | Pantalla táctil, orientación horizontal y APK de depuración mediante GitHub Actions | El flujo de exportación produce un artefacto instalable |

## Riesgos técnicos y respuesta

| Riesgo | Decisión para la primera versión | Verificación |
|---|---|---|
| Rendimiento móvil | Geometría simple, iluminación horneada/aproximada, sin sombras dinámicas de alta resolución | Perfil de rendimiento y límites de resolución definidos en proyecto |
| Física de vehículo | Cuerpo rígido simplificado con raycasts de ruedas en vez de simulación de alto coste | Aceleración, frenado, giro y colisiones observables en escena de prueba |
| Importación de GLB | Validar cada modelo, mantener sólo recursos con licencia clara y crear material de reemplazo si falla | El proyecto abre sin dependencias externas ni rutas rotas |
| Controles táctiles | Acciones abstractas de entrada y botones en HUD, con soporte simultáneo de teclado para depuración | La misma acción opera desde teclado o interfaz táctil |
| Escala de mapa | Distrito procedural por módulos, niebla y límites naturales para reducir la distancia dibujada | Sin texturas grandes ni malla de ciudad completa obligatoria |
| Audio | Efectos y voces opcionales con fuentes permitidas; el juego sigue siendo jugable sin audio | El bus de audio se inicializa sin archivos faltantes |

## Secuencia de implementación

1. Recuperar la configuración válida de Godot 4 y establecer una arquitectura limpia, compatible con Android.
2. Construir una escena prototipo con personaje, cámara, terreno y un vehículo funcional.
3. Añadir controles táctiles, HUD y sistema de objetivos.
4. Integrar arte y sonidos originales o bajo licencias compatibles, documentando su procedencia.
5. Crear la misión inicial, iluminación nocturna y localización contextual.
6. Ejecutar validaciones sin interfaz, producir el APK de depuración en GitHub Actions y conservar el código fuente en el repositorio.

## No incluido aún

Esta fase no incluye mundo persistente masivo, multijugador, contenido de una franquicia ajena, sistema policial, armas realistas, tiendas de pago, publicación en Google Play ni una ciudad a escala real. La arquitectura conserva puntos de extensión para incorporar distritos, encargos, peatones, tráfico y escenas posteriores de manera original.

## Definition of Done

La vertical slice estará terminada cuando el proyecto abra en Godot 4, ejecute la misión de principio a fin en escritorio y controles táctiles, exporte un APK de depuración desde la automatización existente, incluya créditos de assets y tenga una guía clara de compilación para Termux y GitHub Actions.
