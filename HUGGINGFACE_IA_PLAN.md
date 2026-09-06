# Plan de IA para Managua City

## Recomendación general

La IA debe integrarse primero como herramientas offline de producción y como servicios opcionales para el juego. Los modelos grandes no deben incluirse directamente en la APK de Android de gama baja. El cliente Godot debe mantener la lógica canónica, usar `HTTPRequest` con límites y tener respuestas locales de respaldo.

## Modelos recomendados

| Área | Primera opción | Uso recomendado | Licencia / precaución |
|---|---|---|---|
| Diálogos en español | [Qwen2.5-0.5B-Instruct](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct) | Backend pequeño o pruebas locales; generar conversaciones cortas con ficha del NPC | Apache-2.0; validar calidad en español |
| Voz española | [Piper es_ES davefx medium](https://huggingface.co/Trelis/piper-es-es-davefx-medium) | Backend TTS y generación offline de frases preseleccionadas | Modelo CC0; revisar runtime y dependencias |
| Percepción de NPCs | [YOLOX-Nano LiteRT](https://huggingface.co/litert-community/yolox-nano-litert) | Detección ligera de personas/vehículos en Android | Apache-2.0; medir delegate GPU/CPU real |
| Mejora de texturas | [Real-ESRGAN ONNX](https://huggingface.co/anakhiu/realesrgan-onnx) | Mejorar texturas offline, no durante cada frame | BSD-3-Clause; puede inventar detalles |
| Movimiento / mocap | [RTMPose-Body2d](https://huggingface.co/qualcomm/RTMPose-Body2d) | Convertir vídeo de referencia en keypoints para animaciones | Apache-2.0; usar backend u offline |
| Movimiento 3D avanzado | [GEM-X](https://huggingface.co/WANGFEI1989/GEM-X) | Mocap offline para animaciones de calidad | NVIDIA Open Model License; 520M parámetros |
| Efectos de sonido | [Audio-MAGNeT Small](https://huggingface.co/facebook/audio-magnet-small) | Crear pasos, sirenas, ambiente y efectos durante producción | CC-BY-NC-4.0; revisar uso comercial |

## Arquitectura para el juego

Godot debe controlar movimiento, colisiones, misiones, inventario, hechos de la ciudad y estados de los NPCs. La IA sólo debe proponer diálogo, percepción o variaciones de contenido dentro de límites definidos.

Para diálogos, el cliente enviará al backend únicamente el identificador del NPC, idioma, estado permitido y mensaje del jugador. El servidor devolverá JSON validado con una respuesta corta. Deben existir timeout, moderación, rate limiting, caché y fallback local. No se deben guardar claves de API dentro de la APK ni enviar información personal.

Para TTS, conviene generar audio por frase y guardarlo en caché. La APK debe tener líneas pregrabadas para que el juego funcione sin conexión. Piper es la primera opción técnica por tamaño y velocidad; XTTS-v2 ofrece clonación de voz, pero aumenta los riesgos de consentimiento y suplantación.

Para visión, procesar como máximo unos pocos fotogramas por segundo y devolver sólo etiquetas, confianza y cajas. El modelo no debe analizar continuamente la cámara del jugador. Para una ciudad con NPCs, la primera versión puede usar detección de persona y reglas de distancia en Godot.

Para texturas, Real-ESRGAN debe usarse durante el pipeline de arte. Las normales, roughness, metallic y máscaras deben tratarse por separado; nunca aplicar un upscaler fotográfico sin validación a todos los canales de material.

Para animación, RTMPose puede producir keypoints 2D y luego Godot debe aplicar suavizado, IK y retargeting al esqueleto humanoide. GEM-X y ViTPose son más pesados y se reservan para captura offline o backend GPU. El juego no debe depender de mocap en tiempo real para mover NPCs comunes.

## Mejora cuadro por cuadro

Para teléfonos de gama baja, la estrategia recomendada es resolución interna reducida, escalado FSR, DRS, baked lighting, LOD, occlusion culling, instancing y texturas ETC2/ASTC. El denoiser debe ser ligero y opcional. Una red neuronal pesada cuadro por cuadro produciría latencia, consumo, calor y caídas de FPS; no se recomienda como sistema principal del juego.

## Orden de implementación

1. Medir FPS, memoria y temperatura en un teléfono Android real.
2. Finalizar animaciones de caminar, correr, pelea e idle usando los esqueletos riggeados.
3. Integrar diálogo local con opción de backend Qwen.
4. Añadir TTS Piper sólo para conversaciones importantes.
5. Usar Real-ESRGAN offline para mejorar el atlas de vegetación y materiales.
6. Crear un servicio offline de RTMPose para producir animaciones de referencia.
7. Evaluar YOLOX-Nano únicamente si se necesita percepción visual real.
8. Repetir pruebas de rendimiento y revisar licencias antes de distribuir.

## Riesgos legales y técnicos

Las licencias de los pesos, código, runtimes, adaptadores, datasets y salidas pueden ser diferentes. Audio-MAGNeT, MMS TTS y SpinePose tienen restricciones no comerciales; Gemma, Llama, NVIDIA y Stability tienen términos propios. Antes de distribuir un producto comercial hay que revisar el archivo `LICENSE`, los términos vigentes y las obligaciones de atribución de cada versión exacta.

Los modelos pueden alucinar hechos, generar contenido no deseado, producir detecciones erróneas o crear animaciones con jitter. Deben existir validación, filtros, límites, logs mínimos, control de versiones y pruebas con contenido en español latino.
