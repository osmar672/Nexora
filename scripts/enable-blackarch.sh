#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ! -e /etc/arch-release ]]; then
  echo "Este script debe ejecutarse en Arch Linux o Nexora Linux." >&2
  exit 1
fi
if ! command -v curl >/dev/null 2>&1 || ! command -v sha1sum >/dev/null 2>&1; then
  echo "Faltan curl o sha1sum. Instálalos antes de continuar." >&2
  exit 1
fi

if grep -qE '^\[blackarch\][[:space:]]*$' /etc/pacman.conf; then
  echo "El repositorio BlackArch ya está configurado. Sincronizando sistema..."
  sudo pacman -Syu
  exit $?
fi

# Checksum currently published on the official BlackArch downloads page.
# Re-check https://blackarch.org/downloads.html if the checksum changes.
EXPECTED_SHA1="d338a4bb95d9e09f97508da68ac9e17d963b85f6"
TMP_SCRIPT="$(mktemp)"
trap 'rm -f -- "${TMP_SCRIPT}"' EXIT

curl --fail --location --silent --show-error \
  --output "${TMP_SCRIPT}" https://blackarch.org/strap.sh
if ! printf '%s  %s\n' "${EXPECTED_SHA1}" "${TMP_SCRIPT}" | sha1sum --check --status; then
  echo "ERROR: la suma de strap.sh no coincide con el valor publicado en BlackArch." >&2
  echo "No se ejecutó el script. Verifica la suma oficial: https://blackarch.org/downloads.html" >&2
  exit 1
fi

printf 'La suma de strap.sh coincide con la publicada por BlackArch.\n'
echo "Se añadirá un repositorio externo de herramientas de seguridad. Lee su documentación antes de continuar."
read -r -p "¿Continuar con la configuración oficial de BlackArch? [y/N] " answer
case "${answer}" in y|Y|yes|YES|s|S|si|SI|sí|Sí) ;; *) echo "Cancelado."; exit 0 ;; esac

chmod 0755 "${TMP_SCRIPT}"
sudo bash "${TMP_SCRIPT}"
sudo pacman -Syu

echo
echo "BlackArch está configurado si los comandos anteriores terminaron correctamente."
echo "Lista categorías: ./scripts/blackarch-manager.sh list"
echo "Instala una categoría: ./scripts/blackarch-manager.sh install webapp"
echo "No se recomienda instalar todas las herramientas a la vez."
