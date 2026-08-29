# Guía Android con Termux

Esta guía permite trabajar desde **Termux** sin instalar Android Studio. La compilación del APK se realiza en GitHub Actions y el teléfono instala el artefacto de depuración resultante.

> El APK se ejecuta en Android; Termux se usa para administrar el repositorio y disparar la compilación remota. Para editar visualmente escenas de Godot se recomienda usar una instalación de Godot 4 en un equipo de desarrollo, pero no es necesaria para obtener el APK de prueba desde este flujo.

## Preparación

Instala Termux desde una fuente mantenida y, dentro de Termux, instala los paquetes mínimos:

```bash
pkg update && pkg upgrade
pkg install git gh
```

Inicia sesión en GitHub si aún no lo hiciste:

```bash
gh auth login
```

Clona el proyecto y entra en su carpeta:

```bash
gh repo clone kankwj5-eng/Managua-City
cd Managua-City
```

## Obtener una compilación APK

El workflow se ejecuta al enviar cambios a `main` o puede iniciarse manualmente desde la pestaña **Actions** del repositorio. Para enviar una actualización desde Termux:

```bash
git add .
git commit -m "Describe tu cambio"
git push origin main
```

Después de que termine el workflow, descarga el artefacto mediante la interfaz de GitHub o con la CLI:

```bash
gh run list --workflow build.yml
# Sustituye RUN_ID por el identificador del flujo finalizado
gh run download RUN_ID -n ManaguaCity-Android-APK
```

El archivo resultante estará dentro de la carpeta descargada. Para instalarlo, abre el APK desde un gestor de archivos de Android y permite la instalación desde la aplicación que lo abrió cuando el sistema lo solicite.

## Verificación rápida

| Punto | Resultado esperado |
|---|---|
| `git status` | Sin cambios no deseados antes de enviar |
| Workflow Build for Android | Estado **Success** |
| Artefacto | Archivo `ManaguaCity.apk` o APK de depuración equivalente |
| Inicio del juego | HUD, lluvia, personaje y sedán visibles |
| Misión | Mercado azul → caja → malecón |

## Solución de problemas

Si el workflow falla, abre el paso **Build Android APK (debug)** y revisa el primer error de Godot. Los recursos GLB están incluidos en el repositorio y no requieren descargas adicionales durante la exportación. Si cambias `project.godot` o `export_presets.cfg`, conserva el preset llamado exactamente `Android`, ya que el workflow lo invoca con ese nombre.
