# Historial de cambios

## 0.2.0 — 2026-10-21

- Se añadió Nexora Installer: asistente de escritorio con KDialog que prepara la configuración de Archinstall y permite seleccionar conjuntos de herramientas.
- Se mantuvo Archinstall como motor de particionado e instalación; todavía no es un instalador gráfico autónomo.
- Se añadió Nexora Toolset Manager para habilitar opcionalmente el repositorio de BlackArch, listar los grupos publicados e instalar una categoría por elección del usuario.
- El habilitador de BlackArch verifica la suma SHA-1 que publica el proyecto oficial antes de ejecutar su script.
- Se documentaron la construcción desde Windows mediante una VM Arch, la estrategia de toolsets y las limitaciones de esta versión.
- Se corrigieron los nombres de paquetes de ExifTool para usar `perl-image-exiftool`, y se retiró `whatweb` del grupo base de paquetes oficiales para evitar depender de repositorios no habilitados.

## 0.1.0 — base inicial

- Perfil de construcción Archiso para KDE Plasma.
- Manifiestos de paquetes separados por área de desarrollo y seguridad.
- Scripts iniciales de construcción y comprobación de paquetes.
