#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:-iso}"
case "${name}" in
  iso|dev|web|network|forensics|reversing|wireless) ;;
  *) echo "Uso: $0 {iso|dev|web|network|forensics|reversing|wireless}" >&2; exit 2 ;;
esac
file="${ROOT_DIR}/toolsets/${name}-packages.txt"
if [[ "${name}" != iso ]]; then file="${ROOT_DIR}/toolsets/${name}.txt"; fi
if [[ ! -f "${file}" ]]; then echo "No encuentro ${file}" >&2; exit 1; fi
if ! command -v pacman >/dev/null 2>&1; then
  echo "Este comprobador debe ejecutarse en Arch Linux con pacman." >&2; exit 1
fi

missing=()
while IFS= read -r package || [[ -n "${package}" ]]; do
  package="${package%%#*}"
  package="$(printf '%s' "${package}" | xargs)"
  [[ -z "${package}" ]] && continue
  if ! pacman -Si "${package}" >/dev/null 2>&1; then
    missing+=("${package}")
  fi
done < "${file}"

if (( ${#missing[@]} > 0 )); then
  echo "No se encontraron estos paquetes en los repositorios habilitados:"
  printf '  - %s\n' "${missing[@]}"
  echo "Revisa los nombres o si pertenecen a otro repositorio. No continúes con la ISO hasta corregir toolsets/${name}.txt."
  exit 1
fi

echo "OK: todos los paquetes de ${name} aparecen en los repositorios configurados."
