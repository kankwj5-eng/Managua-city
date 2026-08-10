# Managua City: El Camino de la Verdad

Un juego de aventura y supervivencia ambientado en una Nicaragua sumida en el caos.

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

## Estructura del Proyecto Unity

- **Assets/Models/**:
  - `managua_ciudad.glb`: Modelo 3D detallado de la ciudad.
  - `personaje_relieve.glb`: Modelo 3D de Lenner.
- **Assets/Scripts/**:
  - `PlayerController.cs`: Control de movimiento en tercera persona.
- **Assets/Scenes/**:
  - `Gameplay.unity`: Escena principal configurada.

## Configuración para Desarrolladores

### 1. Compilación Automática (APK)
Este repositorio está preparado para compilar automáticamente una APK de Android mediante **GitHub Actions**.

**Requisito previo**: Debes configurar los siguientes `Secrets` en tu repositorio de GitHub (Settings > Secrets and variables > Actions):
- `UNITY_LICENSE`: Tu licencia de Unity en formato XML.
- `UNITY_EMAIL`: Tu correo de Unity.
- `UNITY_PASSWORD`: Tu contraseña de Unity.

### 2. Desarrollo Local
1. Clona el repositorio.
2. Abre el proyecto con **Unity 2022.3 LTS**.
3. Asegúrate de que el modelo de Lenner tenga el componente `CharacterController` y el script `PlayerController.cs` asignado.

---
*Desarrollado con la asistencia de Manus AI.*
