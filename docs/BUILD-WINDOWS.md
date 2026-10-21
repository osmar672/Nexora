# Crear Nexora Linux desde Windows

## Resumen

Usa Windows para editar el proyecto y publicarlo en GitHub. Construye la ISO dentro de una máquina virtual con Arch Linux. Archiso está diseñado para construir imágenes desde Arch Linux; WSL/Ubuntu no es la vía más sencilla para este trabajo.

## A. Preparar Git en Windows

1. Instala Git for Windows desde https://git-scm.com/download/win.
2. Descarga este ZIP o clona el proyecto si ya existe en GitHub.
3. Crea un repositorio vacío en GitHub con el nombre `Nexora-Linux`. No marques opciones para crear README, licencia o `.gitignore` si ya vienen en esta carpeta.
4. Abre PowerShell dentro de la carpeta `Nexora-Linux` y ejecuta (cambia la URL por la de tu cuenta):

```powershell
git init
git add .
git commit -m "feat: initialize Nexora Linux DevSec project"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/Nexora-Linux.git
git push -u origin main
```

Si Git pide identidad, configúrala una vez:

```powershell
git config --global user.name "Tu nombre"
git config --global user.email "tu-correo@example.com"
```

No guardes tokens, claves privadas, archivos `.env` ni contraseñas en el repositorio.

## B. Crear una VM para construir la ISO

1. Instala VirtualBox desde https://www.virtualbox.org/wiki/Downloads (o usa otro virtualizador que ya tengas).
2. Descarga la ISO oficial de Arch Linux desde https://archlinux.org/download/.
3. Crea una máquina virtual con, como punto de partida, 4 núcleos, 8 GB de RAM y 60–100 GB de disco virtual dinámico. Si tu PC tiene recursos limitados, la construcción será más lenta y necesitarás reducir el espacio disponible para toolsets.
4. Arranca la VM desde la ISO de Arch. Para instalar Arch en la VM, ejecuta `archinstall` y elige un sistema base sencillo. No necesitas KDE dentro de la VM de construcción; KDE va en la ISO Nexora que vas a generar.
5. Reinicia en el Arch instalado y conéctalo a Internet.

## C. Construir la ISO dentro de Arch

Actualiza e instala los requisitos:

```bash
sudo pacman -Syu --needed archiso git python qemu-desktop edk2-ovmf
```

Clona el repositorio de GitHub:

```bash
git clone https://github.com/TU-USUARIO/Nexora-Linux.git
cd Nexora-Linux
```

Prepara el perfil y construye:

```bash
./scripts/check-packages.sh iso
./scripts/bootstrap-profile.sh
./scripts/build-iso.sh
```

No uses `sudo` delante de los scripts; `mkarchiso` administra los pasos necesarios. La primera construcción descarga paquetes y puede ocupar decenas de GB entre caché, perfil temporal e ISO.

La ISO quedará en `out/`. Comprueba el nombre real con:

```bash
ls -lh out/
```

## D. Probar

Prueba la ISO en una VM, no en el disco principal. Desde el entorno Arch con qemu instalado, puedes iniciar:

```bash
run_archiso -i out/NOMBRE-REAL-DE-LA-ISO.iso
```

Si `run_archiso` no está disponible en tu sistema, usa la ISO como disco de arranque de una VM nueva en VirtualBox.

Comprueba KDE Plasma, inicio de sesión, red, terminales y que el instalador se abre. No instales en un disco real hasta haber probado la ISO y respaldado todos los datos.

## E. Subir cambios de vuelta a GitHub

Después de modificar manifiestos o scripts:

```bash
git status
git add -A
git commit -m "feat: add development and security toolsets"
git push
```

La ISO está excluida por `.gitignore`: no conviene subirla al repositorio de código porque puede ocupar varios GB. Publícala más adelante como un Release, junto con su suma SHA-256.
