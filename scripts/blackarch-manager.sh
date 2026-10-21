#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'HELP'
Nexora Toolset Manager — BlackArch opcional

Comandos:
  ./scripts/blackarch-manager.sh gui       Abrir el menú gráfico KDE
  ./scripts/blackarch-manager.sh enable    Configurar el repositorio oficial
  ./scripts/blackarch-manager.sh list      Listar categorías disponibles
  ./scripts/blackarch-manager.sh install <categoria>

Ejemplo:
  ./scripts/blackarch-manager.sh install webapp

El repositorio BlackArch es externo y opcional. No instales todas las categorías por defecto.
HELP
}

case "${1:-gui}" in
  enable)
    exec "${SCRIPT_DIR}/enable-blackarch.sh"
    ;;
  list)
    exec "${SCRIPT_DIR}/list-blackarch-groups.sh"
    ;;
  install)
    exec "${SCRIPT_DIR}/install-blackarch-group.sh" "${2:-}"
    ;;
  gui)
    if ! command -v kdialog >/dev/null 2>&1; then
      usage
      exit 1
    fi
    if ! grep -qE '^\[blackarch\][[:space:]]*$' /etc/pacman.conf; then
      if kdialog --title "Nexora Toolset Manager" --yesno \
        "BlackArch es un repositorio externo opcional. ¿Quieres abrir una terminal para configurarlo y verificar su script oficial?"; then
        if command -v konsole >/dev/null 2>&1; then
          konsole --hold -e "${SCRIPT_DIR}/enable-blackarch.sh"
        else
          "${SCRIPT_DIR}/enable-blackarch.sh"
        fi
      fi
      exit 0
    fi
    mapfile -t groups < <("${SCRIPT_DIR}/list-blackarch-groups.sh")
    if (( ${#groups[@]} == 0 )); then
      kdialog --title "Nexora Toolset Manager" --error "No se encontraron categorías. Comprueba la conexión y sincroniza pacman."
      exit 1
    fi
    args=(--title "Nexora Toolset Manager" --menu "Selecciona una categoría BlackArch. Solo se instalará el grupo que elijas; pacman mostrará los paquetes y pedirá confirmación.")
    for group in "${groups[@]}"; do
      label="${group#blackarch-}"
      label="${label//-/ }"
      args+=("${group#blackarch-}" "${label}")
    done
    category="$(kdialog "${args[@]}")" || exit 0
    [[ -n "${category}" ]] || exit 0
    if command -v konsole >/dev/null 2>&1; then
      konsole --hold -e "${SCRIPT_DIR}/install-blackarch-group.sh" "${category}"
    else
      "${SCRIPT_DIR}/install-blackarch-group.sh" "${category}"
    fi
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
