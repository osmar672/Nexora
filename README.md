# Nexora Linux — Dev & Security

Nexora Linux es un proyecto comunitario basado en Arch Linux, enfocado en programación, DevOps y ciberseguridad autorizada. Usa Archiso para generar una ISO live con KDE Plasma y un conjunto inicial de herramientas.

> **Estado:** prototipo de desarrollo. No es una distribución estable ni auditada. Las herramientas de pruebas de seguridad deben utilizarse únicamente en sistemas propios o con autorización explícita.

## Importante si desarrollas desde Windows

Puedes editar este repositorio en Windows y subirlo a GitHub con Git. Para construir la ISO, utiliza una máquina virtual con Arch Linux: Archiso está documentado y probado principalmente para construir desde Arch Linux. No intentes construir la ISO directamente desde PowerShell.

Guía paso a paso: [`docs/BUILD-WINDOWS.md`](docs/BUILD-WINDOWS.md).

## Qué incluye la primera versión

- KDE Plasma y SDDM en el entorno live.
- Navegador, terminal, editor, Git, Python y Node.js.
- Herramientas iniciales de red y seguridad defensiva/pentest autorizado.
- Acceso al instalador guiado `archinstall`.
- Manifiestos de paquetes por áreas para ampliar el sistema.
- Scripts para preparar el perfil y generar la ISO.

## Qué NO promete todavía

- No incluye literalmente miles de herramientas dentro de la ISO base.
- No tiene un instalador gráfico propio; el lanzador abre `archinstall`.
- Los paquetes del entorno live no se copian automáticamente al sistema instalado. Después de instalar Nexora/Arch, clona el repositorio y ejecuta el instalador de toolsets que necesites.
- El proyecto no está auditado para uso empresarial ni debe utilizarse como sistema de producción sin pruebas adicionales.

## Construir la ISO desde una VM con Arch Linux

Instala los requisitos en la VM:

```bash
sudo pacman -Syu --needed archiso git python qemu-desktop edk2-ovmf
```

Clona tu repositorio (reemplaza la URL por la tuya):

```bash
git clone https://github.com/TU-USUARIO/Nexora-Linux.git
cd Nexora-Linux
```

Valida que los paquetes de la ISO estén disponibles y luego construye:

```bash
./scripts/check-packages.sh iso
./scripts/bootstrap-profile.sh
./scripts/build-iso.sh
```

La imagen se guarda dentro de `out/`. El nombre exacto puede variar según `profiledef.sh`.

## Añadir grupos de herramientas después de instalar el sistema

Desde el sistema Nexora ya instalado, clona el repositorio y ejecuta, por ejemplo:

```bash
./scripts/install-toolset.sh dev
./scripts/install-toolset.sh web
./scripts/install-toolset.sh network
./scripts/install-toolset.sh forensics
./scripts/install-toolset.sh reversing
./scripts/install-toolset.sh wireless
```

Cada grupo usa paquetes de los repositorios configurados en el sistema. Si un paquete no existe para la versión o los repositorios habilitados, `pacman` lo señalará; no uses `--overwrite='*'` como solución genérica.

## Acceso a miles de herramientas

BlackArch mantiene un repositorio adicional de herramientas de seguridad basado en Arch. Nexora lo documenta como opción separada, no como requisito de la ISO base: la ISO completa de BlackArch es muy grande y su propio sitio desaconseja la instalación Full para la mayoría de usuarios por posibles conflictos de instalación y actualización. Consulta [`docs/BLACKARCH-OPTIONAL.md`](docs/BLACKARCH-OPTIONAL.md) y verifica las instrucciones oficiales antes de añadir repositorios de terceros.

## Estructura del repositorio

```text
Nexora-Linux/
├── README.md
├── LICENSE
├── .gitignore
├── scripts/
│   ├── bootstrap-profile.sh
│   ├── build-iso.sh
│   ├── check-packages.sh
│   └── install-toolset.sh
├── toolsets/
│   ├── iso-packages.txt
│   ├── dev.txt
│   ├── web.txt
│   ├── network.txt
│   ├── forensics.txt
│   ├── reversing.txt
│   └── wireless.txt
├── docs/
│   ├── BUILD-WINDOWS.md
│   ├── TOOLING-STRATEGY.md
│   └── BLACKARCH-OPTIONAL.md
└── branding/
    └── README.md
```

## Roadmap sugerida

1. Construir la ISO base y probarla en QEMU/VirtualBox.
2. Corregir problemas de arranque, red, KDE y paquetes.
3. Añadir branding y temas propios.
4. Mejorar la instalación para aplicar las selecciones de software al sistema instalado.
5. Preparar sumas SHA-256, notas de versión, pruebas de actualización y una política de seguridad.
