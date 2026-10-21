# Estrategia de herramientas

## Base + conjuntos opcionales + repositorio externo

Nexora usa tres capas:

1. **ISO base:** un escritorio KDE usable, red, utilidades esenciales y una selección pequeña de herramientas.
2. **Toolsets de Nexora:** manifiestos propios para desarrollo, web, redes, forense, ingeniería inversa y Wi-Fi. Se pueden seleccionar desde Nexora Installer durante el despliegue o instalar más tarde con `scripts/install-toolset.sh`.
3. **BlackArch opcional:** repositorio externo que amplía el catálogo con miles de herramientas. Solo se habilita explícitamente y sus grupos se consultan dinámicamente desde pacman.

No se intenta incluir todas las herramientas en la ISO base porque aumentaría mucho el tamaño, el tiempo de construcción, la superficie de mantenimiento y la posibilidad de conflictos.

## Manifiestos propios

- `dev.txt`: compilación, lenguajes, depuración y contenedores.
- `web.txt`: pruebas de aplicaciones web en entornos autorizados.
- `network.txt`: análisis y diagnóstico de red.
- `forensics.txt`: recuperación y análisis de archivos/evidencias.
- `reversing.txt`: depuración e ingeniería inversa.
- `wireless.txt`: herramientas para análisis inalámbrico con hardware compatible.
- `iso-packages.txt`: paquetes que se instalan en el entorno live.

Los manifiestos son un punto de partida, no una garantía de que cada paquete exista para siempre en los repositorios configurados. Antes de publicar una ISO, ejecuta `scripts/check-packages.sh` en un Arch actualizado y soluciona los nombres que no estén disponibles.

## Seguridad responsable

Usa escaneos, auditorías, pruebas inalámbricas y herramientas de explotación únicamente en sistemas propios o con permiso explícito. Mantén los laboratorios aislados de redes y dispositivos de producción.
