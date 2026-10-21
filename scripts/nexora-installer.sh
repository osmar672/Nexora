#!/usr/bin/env bash
set -Eeuo pipefail

# Nexora Installer 0.2.0
# A branded graphical setup wizard that prepares an Archinstall configuration.
# Disk partitioning and account credentials remain in Archinstall's guided flow.

APP_NAME="Nexora Installer"
DATA_DIR="/usr/share/nexora"
if [[ ! -d "${DATA_DIR}/toolsets" ]]; then
  ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
  DATA_DIR="${ROOT_DIR}"
fi
TOOLSET_DIR="${DATA_DIR}/toolsets"
CONFIG_FILE="$(mktemp /tmp/nexora-archinstall.XXXXXX.json)"
cleanup() { rm -f -- "${CONFIG_FILE}"; }
trap cleanup EXIT

notify_error() {
  if command -v kdialog >/dev/null 2>&1; then
    kdialog --error "$1" --title "$APP_NAME" || true
  else
    printf 'Error: %s\n' "$1" >&2
  fi
}

if [[ ${EUID} -eq 0 ]]; then
  notify_error "Abre Nexora Installer desde el menú del escritorio como usuario normal. El programa solicitará permisos al iniciar la instalación."
  exit 1
fi
if ! command -v kdialog >/dev/null 2>&1; then
  echo "Falta kdialog. En Arch: sudo pacman -S --needed kdialog" >&2
  exit 1
fi
if ! command -v archinstall >/dev/null 2>&1; then
  notify_error "No se encontró archinstall. Comprueba que el paquete está incluido en la ISO."
  exit 1
fi

kdialog --title "$APP_NAME" --yesno \
  "Bienvenido a Nexora Linux.\n\nEste asistente prepara una instalación de Arch con KDE Plasma y te permite elegir herramientas adicionales.\n\nLa selección del disco, particionado y credenciales se realizará en el instalador guiado. Revisa cada paso: elegir borrar un disco puede eliminar sus datos." \
  --yes-label "Continuar" --no-label "Cancelar" || exit 0

if [[ ! -d "${TOOLSET_DIR}" ]]; then
  notify_error "No se encontró el catálogo de paquetes: ${TOOLSET_DIR}"
  exit 1
fi

choice="$(kdialog --title "$APP_NAME" --checklist \
  "Selecciona los conjuntos opcionales para instalar en el sistema. KDE Plasma se configura como escritorio principal. Puedes elegir varios." \
  dev "Programación y DevOps" on \
  web "Auditoría de aplicaciones web (laboratorios autorizados)" off \
  network "Redes y diagnóstico" on \
  forensics "Forense digital" off \
  reversing "Ingeniería inversa" off \
  wireless "Redes inalámbricas" off)" || exit 0

# KDialog normally returns selected IDs separated by spaces. IDs have no spaces.
choice="${choice//\"/}"
read -r -a selected <<< "${choice}"

if ! python3 - "${TOOLSET_DIR}" "${CONFIG_FILE}" "${selected[@]}" <<'PY'
import json
import pathlib
import sys

manifest_dir = pathlib.Path(sys.argv[1])
config_path = pathlib.Path(sys.argv[2])
selected = sys.argv[3:]
allowed = {"dev", "web", "network", "forensics", "reversing", "wireless"}
packages = []
for name in selected:
    if name not in allowed:
        raise SystemExit(f"Toolset no permitido: {name}")
    path = manifest_dir / f"{name}.txt"
    if not path.is_file():
        raise SystemExit(f"No se encontró el manifiesto: {path}")
    for line in path.read_text(encoding="utf-8").splitlines():
        package = line.split("#", 1)[0].strip()
        if package:
            packages.append(package)

# Deduplicate and sort to keep the generated config deterministic.
packages = sorted(set(packages))
config = {
    "bootloader": "grub-install",
    "kernels": ["linux"],
    "mirror-region": {},
    "profile": {"main": "desktop", "details": "plasma"},
    "greeter_type": "sddm",
    "audio_config": {"audio": "pipewire"},
    "network_config": {"type": "nm"},
    "services": ["NetworkManager", "sddm"],
    "ntp": True,
    "timezone": "America/Costa_Rica",
    "packages": packages,
}
config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
print(f"Se prepararon {len(packages)} paquetes opcionales.")
PY
then
  notify_error "No se pudo preparar la configuración de instalación. Revisa los manifiestos de toolsets."
  exit 1
fi

kdialog --title "$APP_NAME" --msgbox \
  "La configuración de Nexora está lista. Se abrirá el instalador guiado.\n\n1. Revisa el disco de destino y el tipo de particionado.\n2. Configura usuario y contraseña.\n3. Confirma solo cuando estés seguro de que el disco correcto está seleccionado.\n\nLos paquetes elegidos se pasarán a Archinstall." || true

# The command stays in this terminal so Archinstall can request credentials safely.
if sudo archinstall --config "${CONFIG_FILE}"; then
  status=0
else
  status=$?
fi
if (( status == 0 )); then
  kdialog --title "$APP_NAME" --msgbox \
    "Archinstall terminó. Reinicia cuando el instalador indique que es seguro hacerlo.\n\nLas herramientas adicionales de BlackArch se pueden instalar luego desde Nexora Toolset Manager; no se instalan todas automáticamente." || true
fi
exit "$status"
