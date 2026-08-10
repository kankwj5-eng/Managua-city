# Managua City: El Camino de la Verdad (Godot 4 Edition)

Un juego de aventura y supervivencia en 3D ambientado en una Nicaragua sumida en el caos. Este proyecto ha sido migrado de Unity a **Godot Engine 4 (v4.3+)**, un motor 100% gratuito y de código abierto sin cargos de licencias.

## Historia

El caos comenzó sin aviso. Las comunicaciones cayeron, varias ciudades quedaron aisladas y extraños grupos comenzaron a aparecer por todo el país.

**Lenner**, nuestro protagonista, recibe una última comunicación de su hermana, una brillante científica que trabajaba en un proyecto secreto. Ella le dice:
> “No confíes en nadie. Yo tengo las respuestas… pero si me encuentran, todo habrá terminado.”

Después, la comunicación se corta. Lenner descubre que su hermana posee los conocimientos necesarios para detener el caos y descubrir qué lo provocó realmente. El problema es que ha desaparecido y nadie sabe dónde está.

Así comienza su viaje. Con su camisa de la selección de Nicaragua, pantalón largo y el equipo que consigue durante la aventura, Lenner tendrá que atravesar ciudades, carreteras, zonas rurales y lugares abandonados mientras intenta encontrar pistas sobre el paradero de su hermana.

Pero el camino será cada vez más difícil. Los enemigos también la están buscando. Cada pista lo acerca a ella, pero también revela algo más inquietante: su hermana no desapareció por accidente. Alguien la está escondiendo porque conoce la verdad sobre el origen del caos.

Y cuando Lenner finalmente descubre dónde podría estar... **la verdadera aventura apenas comienza.**

## Personaje Principal: Lenner

- **Atuendo**: Camisa de la selección de Nicaragua y pantalón largo.
- **Misión**: Encontrar a su hermana científica y detener el origen del caos.
- **Habilidades**: Exploración, recolección de equipo y combate táctico.
- **Equipamiento**: Arma (pistola) y cuchillo.

## Estructura del Proyecto Godot 4

La estructura del proyecto sigue las convenciones recomendadas de organización para Godot 4:

- **assets/models/**:
  - `managua_ciudad.glb`: Modelo 3D detallado de la ciudad.
  - `personaje_relieve.glb`: Modelo 3D del protagonista Lenner (con pistola y cuchillo).
- **scenes/**: Carpeta dedicada a guardar las escenas de Godot (`.tscn`).
- **scripts/**: Carpeta dedicada a los scripts de comportamiento de juego (`.gd`).

## Configuración para Desarrolladores

### 1. Compilación Automática (Android APK)
Este repositorio está preparado para compilar automáticamente una APK firmada de Android en **GitHub Actions** cada vez que se hace un commit a las ramas `main` o `master`.

Para que el APK se firme de forma segura para producción, debes configurar los siguientes **Secrets** en tu repositorio de GitHub (**Settings > Secrets and variables > Actions**):

1. **`ANDROID_KEYSTORE_BASE64`**: El archivo de tu Keystore codificado en formato Base64.
   - *¿Cómo generarlo?* Puedes usar el siguiente comando en tu terminal local para convertir tu archivo `.keystore` a texto Base64:
     - Linux/macOS: `base64 release.keystore -w 0 > keystore_b64.txt`
     - Windows (PowerShell): `[Convert]::ToBase64String([IO.File]::ReadAllBytes("release.keystore")) > keystore_b64.txt`
     - Windows (Command Prompt): `certutil -encodehex -f release.keystore encoded.txt 0x40000001`
   - Copia todo el contenido de este archivo de texto generado y guárdalo en el secret.
2. **`ANDROID_KEYSTORE_PASSWORD`**: La contraseña maestra de tu almacén de claves (Keystore).
3. **`ANDROID_KEY_ALIAS`**: El alias asignado a la clave de firma dentro de tu Keystore.
4. **`ANDROID_KEY_PASSWORD`**: La contraseña específica de tu clave de firma.

*Nota:* Si no configuras los secrets, el workflow de GitHub Actions generará una advertencia y continuará con la exportación, pero el APK final podría no estar firmado adecuadamente para producción.

### 2. Desarrollo Local
1. Clona el repositorio.
2. Instala e inicia **Godot Engine v4.3** (versión Standard).
3. Importa el proyecto seleccionando el archivo `project.godot` ubicado en la raíz.
4. Abre la escena principal que definas para comenzar a desarrollar.

---
*Desarrollado con la asistencia de Manus AI.*
