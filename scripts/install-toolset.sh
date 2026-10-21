#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLSET_DIR="${ROOT_DIR}/toolsets"

usage() {
  echo "Uso: $0 {dev|web|network|forensics|reversing|wireless}"
}

if [[ "${EUID}" -ne 0 ]]; then
  echo "Ejecuta con sudo: sudo $0 <grupo>" >&2
  exit 1
fi

name="${1:-}"
case "${name}" in
  dev|web|network|forensics|reversing|wireless) ;;
  *) usage >&2; exit 2 ;;
esac
file="${TOOLSET_DIR}/${name}.txt"
if [[ ! -f "${file}" ]]; then
  echo "No encuentro el manifiesto ${file}. Clona el repositorio completo." >&2
  exit 1
fi

mapfile -t packages < <(sed 's/#.*//' "${file}" | xargs -n1 | sed '/^$/d' | sort -u)
if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "El grupo ${name} no contiene paquetes." >&2
  exit 1
fi
printf 'Instalar grupo: %s\nPaquetes: %s\n' "${name}" "${packages[*]}"
echo "Solo continúa si reconoces y necesitas estas herramientas."
pacman -Syu --needed -- "${packages[@]}"
