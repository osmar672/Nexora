# Estrategia de herramientas

## No incluir todas las herramientas en la ISO base

Una ISO con miles de herramientas ocupa mucho espacio, tarda más en construirse y actualizarse, y aumenta la superficie de mantenimiento. Nexora mantiene un conjunto base y manifiestos por área para instalar cuando hacen falta.

Los toolsets incluidos aquí son puntos de partida, no una lista exhaustiva ni una garantía de que cada paquete siga estando disponible en todos los espejos/ramas de Arch. Antes de una publicación, prueba la construcción en un Arch actualizado y corrige los nombres que el gestor de paquetes reporte como inexistentes.

## Áreas sugeridas

- `dev.txt`: herramientas de compilación, lenguajes, depuración y contenedores.
- `web.txt`: pruebas de aplicaciones web en entornos autorizados.
- `network.txt`: análisis y diagnóstico de red.
- `forensics.txt`: recuperación y análisis de archivos/evidencias.
- `reversing.txt`: depuración e ingeniería inversa.
- `wireless.txt`: herramientas para análisis inalámbrico con hardware compatible.

## Seguridad responsable

Ejecuta escaneos, auditorías, pruebas inalámbricas y herramientas de explotación únicamente en sistemas propios o con permiso explícito. Mantén máquinas de laboratorio separadas de redes y dispositivos de producción.
