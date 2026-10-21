#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="${ROOT_DIR}/profile"
OUT_DIR="${ROOT_DIR}/out"
WORK_DIR="${ROOT_DIR}/work"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Ejecuta mkarchiso como usuario normal, sin sudo." >&2
  exit 1
fi
if [[ ! -d "${PROFILE_DIR}" ]]; then
  echo "No existe profile/. Primero ejecuta ./scripts/bootstrap-profile.sh" >&2
  exit 1
fi
mkdir -p "${OUT_DIR}"
mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${PROFILE_DIR}"
echo
echo "ISO creada en ${OUT_DIR}"
ls -lh "${OUT_DIR}"/*.iso
