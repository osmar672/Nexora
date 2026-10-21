#!/usr/bin/env bash
set -Eeuo pipefail
category="${1:-}"
if [[ ! "${category}" =~ ^[a-z0-9-]+$ ]]; then
  echo "Uso: $0 <categoría> (ejemplo: webapp, scanner, forensics)" >&2
  exit 2
fi
if [[ ! -e /etc/arch-release ]]; then
  echo "Este script debe ejecutarse en Arch Linux o Nexora Linux." >&2
  exit 1
fi
if ! grep -qE '^\[blackarch\][[:space:]]*$' /etc/pacman.conf; then
  echo "BlackArch no está habilitado. Ejecuta enable-blackarch.sh primero." >&2
  exit 1
fi

group="blackarch-${category}"
if ! pacman -Sg "${group}" 2>/dev/null | grep -q .; then
  echo "No se encontró el grupo ${group}. Lista grupos válidos con: ./scripts/blackarch-manager.sh list" >&2
  exit 1
fi
count="$(pacman -Sg "${group}" | awk '{print $2}' | sort -u | wc -l | tr -d ' ')"
echo "Categoría: ${group}"
echo "Paquetes declarados en el grupo: ${count}"
echo "Se actualizará el sistema y pacman mostrará el resumen antes de instalar."
echo "Instala únicamente herramientas que necesites y uses en sistemas autorizados."
read -r -p "¿Continuar? [y/N] " answer
case "${answer}" in y|Y|yes|YES|s|S|si|SI|sí|Sí) ;; *) echo "Cancelado."; exit 0 ;; esac
sudo pacman -Syu --needed "${group}"
