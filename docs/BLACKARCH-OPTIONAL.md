# BlackArch opcional y catálogo ampliado

BlackArch es un repositorio no oficial compatible con Arch y anuncia más de 2.800 herramientas. Nexora no incorpora todas estas herramientas en su ISO base: se habilitan después de instalar el sistema, y se instalan únicamente las categorías necesarias.

Fuentes oficiales:

- Descargas e instrucciones de instalación: https://blackarch.org/downloads.html
- Repositorio oficial: https://github.com/BlackArch/blackarch
- Script oficial: https://blackarch.org/strap.sh

## Desde el repositorio clonado

En un sistema Nexora/Arch ya instalado y actualizado:

```bash
./scripts/enable-blackarch.sh
./scripts/blackarch-manager.sh list
./scripts/blackarch-manager.sh install webapp
```

También puedes abrir `./scripts/blackarch-manager.sh gui` en un escritorio KDE para escoger una categoría. En la ISO live se incluye el acceso **Nexora Toolset Manager**.

El habilitador descarga `strap.sh` desde el dominio oficial, verifica la suma SHA-1 publicada en la página oficial consultada al preparar esta versión, pregunta antes de ejecutarla como administrador y actualiza el sistema. Si la suma cambia, el script se detiene de forma segura: verifica el valor nuevo en https://blackarch.org/downloads.html antes de actualizarlo en Nexora.

## Instalar categorías

El gestor obtiene las categorías desde los grupos que publica pacman, en lugar de mantener una lista estática que podría quedarse obsoleta. Ejemplos posibles (si aparecen en el repositorio habilitado):

```bash
./scripts/blackarch-manager.sh install webapp
./scripts/blackarch-manager.sh install scanner
./scripts/blackarch-manager.sh install forensics
```

El comando de instalación ejecuta `pacman -Syu --needed` con el grupo seleccionado; pacman muestra el resumen y pide confirmación. No se usa `--overwrite='*'` automáticamente.

## Por qué no instalar todo

Tener acceso a un catálogo de miles de herramientas no significa que todas deban instalarse juntas. Instalar todas puede ocupar mucho espacio, provocar conflictos y complicar actualizaciones. Nexora prioriza conjuntos por área y deja BlackArch como opción explícita. Ejecuta escaneos y pruebas solo en equipos, redes y aplicaciones propios o con autorización explícita.
