#!/usr/bin/env bash
set -Eeuo pipefail
if ! command -v pacman >/dev/null 2>&1; then
  echo "Este script requiere Arch Linux/Nexora Linux y pacman." >&2
  exit 1
fi
if ! grep -qE '^\[blackarch\][[:space:]]*$' /etc/pacman.conf; then
  echo "BlackArch no está habilitado. Ejecuta: ./scripts/enable-blackarch.sh" >&2
  exit 1
fi
pacman -Sg | awk '$1 ~ /^blackarch-/ { print $1 }' | sort -u
