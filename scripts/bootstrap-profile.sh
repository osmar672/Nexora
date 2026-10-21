#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="${ROOT_DIR}/profile"
PACKAGES_FILE="${ROOT_DIR}/toolsets/iso-packages.txt"
SOURCE_PROFILE="/usr/share/archiso/configs/releng"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Ejecuta este script como usuario normal, sin sudo." >&2
  exit 1
fi

if [[ ! -e /etc/arch-release ]]; then
  echo "Este script debe ejecutarse en Arch Linux. En Windows, usa una VM con Arch Linux." >&2
  exit 1
fi

if ! command -v mkarchiso >/dev/null 2>&1 || [[ ! -d "${SOURCE_PROFILE}" ]]; then
  echo "Falta archiso. Instálalo con: sudo pacman -S --needed archiso" >&2
  exit 1
fi

if [[ -e "${PROFILE_DIR}" ]]; then
  echo "Ya existe ${PROFILE_DIR}; no se sobrescribirá." >&2
  echo "Si deseas empezar otra vez, renombra o elimina el perfil manualmente después de respaldarlo." >&2
  exit 1
fi

mkdir -p "${ROOT_DIR}"
cp -a "${SOURCE_PROFILE}" "${PROFILE_DIR}"

# Archiso profile package filename can differ between versions.
if [[ -f "${PROFILE_DIR}/packages.x86_64" ]]; then
  PROFILE_PACKAGES="${PROFILE_DIR}/packages.x86_64"
elif [[ -f "${PROFILE_DIR}/packages.arch" ]]; then
  PROFILE_PACKAGES="${PROFILE_DIR}/packages.arch"
else
  echo "No encuentro packages.x86_64 ni packages.arch en el perfil releng." >&2
  exit 1
fi

# Add each listed package once, preserving the baseline packages from releng.
while IFS= read -r package || [[ -n "${package}" ]]; do
  package="${package%%#*}"
  package="$(printf '%s' "${package}" | xargs)"
  [[ -z "${package}" ]] && continue
  if ! grep -qxF "${package}" "${PROFILE_PACKAGES}"; then
    printf '%s\n' "${package}" >> "${PROFILE_PACKAGES}"
  fi
done < "${PACKAGES_FILE}"

python - "${PROFILE_DIR}/profiledef.sh" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
values = {
    "iso_name": "nexora",
    "iso_label": "NEXORA_202610",
    "iso_publisher": "Nexora Linux Project",
    "iso_application": "Nexora Linux Dev and Security Live",
    "iso_version": "0.1.0",
    "install_dir": "nexora",
}
for key, value in values.items():
    pattern = rf"(?m)^{re.escape(key)}=.*$"
    replacement = f'{key}="{value}"'
    if re.search(pattern, text):
        text = re.sub(pattern, replacement, text, count=1)
    else:
        text += f"\n{replacement}\n"
path.write_text(text)
PY

# The live session gets a temporary user; it is created at boot before SDDM.
mkdir -p "${PROFILE_DIR}/airootfs/usr/local/bin"
cat > "${PROFILE_DIR}/airootfs/usr/local/bin/nexora-live-setup" <<'LIVESETUP'
#!/usr/bin/bash
set -euo pipefail
if ! id nexora >/dev/null 2>&1; then
  useradd --create-home --uid 1000 --user-group --groups wheel --shell /bin/bash nexora
fi
install -d -o root -g root -m 0750 /etc/sudoers.d
printf '%s\n' 'nexora ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-nexora-live
chmod 0440 /etc/sudoers.d/10-nexora-live
LIVESETUP
chmod 0755 "${PROFILE_DIR}/airootfs/usr/local/bin/nexora-live-setup"

mkdir -p "${PROFILE_DIR}/airootfs/etc/systemd/system"
cat > "${PROFILE_DIR}/airootfs/etc/systemd/system/nexora-live-setup.service" <<'SERVICE'
[Unit]
Description=Prepare the temporary Nexora live user
Before=sddm.service
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nexora-live-setup
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE

mkdir -p "${PROFILE_DIR}/airootfs/etc/systemd/system/multi-user.target.wants"
ln -sfn ../nexora-live-setup.service \
  "${PROFILE_DIR}/airootfs/etc/systemd/system/multi-user.target.wants/nexora-live-setup.service"
ln -sfn /usr/lib/systemd/system/NetworkManager.service \
  "${PROFILE_DIR}/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
ln -sfn /usr/lib/systemd/system/sddm.service \
  "${PROFILE_DIR}/airootfs/etc/systemd/system/display-manager.service"
ln -sfn /usr/lib/systemd/system/graphical.target \
  "${PROFILE_DIR}/airootfs/etc/systemd/system/default.target"

mkdir -p "${PROFILE_DIR}/airootfs/etc/sddm.conf.d"
cat > "${PROFILE_DIR}/airootfs/etc/sddm.conf.d/10-nexora-autologin.conf" <<'SDDM'
[Autologin]
User=nexora
Session=plasma.desktop
Relogin=false
SDDM

mkdir -p "${PROFILE_DIR}/airootfs/usr/share/applications"
cat > "${PROFILE_DIR}/airootfs/usr/share/applications/nexora-installer.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Instalar Nexora Linux
Comment=Abre el instalador guiado de Arch Linux
Exec=konsole -e sudo archinstall
Icon=system-software-install
Terminal=false
Categories=System;
DESKTOP

# Embed a copy of the toolset installer in the live environment for reference.
mkdir -p "${PROFILE_DIR}/airootfs/usr/share/nexora/toolsets"
cp "${ROOT_DIR}/scripts/install-toolset.sh" "${PROFILE_DIR}/airootfs/usr/share/nexora/install-toolset.sh"
cp "${ROOT_DIR}"/toolsets/*.txt "${PROFILE_DIR}/airootfs/usr/share/nexora/toolsets/"

cat <<EOF2
Perfil Nexora preparado en: ${PROFILE_DIR}
Siguiente paso: ./scripts/build-iso.sh
Recuerda probar la ISO en una VM. Los paquetes de la sesión live no se transfieren automáticamente al sistema instalado.
EOF2
