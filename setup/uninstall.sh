#!/usr/bin/env sh
# Remove the user-level Glacé Shell installation.
set -eu

if [ -z "${HOME:-}" ]; then
    printf '%s\n' 'HOME must be set.' >&2
    exit 1
fi

CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
DATA_HOME=${XDG_DATA_HOME:-"${HOME}/.local/share"}
INSTALL_ROOT="$CONFIG_HOME/GlaceShell"
SERVICE_DIR="$CONFIG_HOME/systemd/user"
SDDM_THEME_ROOT=${SDDM_THEME_ROOT:-"$DATA_HOME/sddm/themes"}
THEME_DIR="$SDDM_THEME_ROOT/GlaceShell"

if [ "${GLACE_SHELL_SKIP_SERVICE:-0}" != "1" ] && command -v systemctl >/dev/null 2>&1; then
    systemctl --user disable --now glace-ipc.service 2>/dev/null || true
    systemctl --user daemon-reload 2>/dev/null || true
fi

rm -f "$SERVICE_DIR/glace-ipc.service"
if [ -f "$INSTALL_ROOT/.kxkbrc-installed" ]; then
    rm -f "$CONFIG_HOME/kxkbrc"
fi
rm -rf "$INSTALL_ROOT" "$THEME_DIR"

printf '%s\n' 'Glacé Shell user configuration and SDDM theme removed.'
